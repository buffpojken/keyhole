class SatParser < EventMachine::Connection
    
  attr_accessor :db, :imei, :latest_location, :hdop, :connected, :status, :session_key
    
  def post_init(*args)
    $clients[self.signature] = true
    # Here, check if the device exists - if yes, update it to online and defer the response, 
    # if not - notify the GUI that an unknown tracker has tried to connect, did you forget to add it to the session?
    self.connected  = false
    self.status     = 2 
  end
  
  
  def receive_data(data)
    data = data.split(",")
    # Store the unique reference to this specific tracker.
    self.imei = data[0].gsub("$", "")    
    # Since we can't identify the tracker until we receive an event, we'll defer notifying any clients about it
    # until we CAN identify it. This means that these events will likely occur very quickly after one another
    # if the tracker already has GPS-connectivity, otherwise, they might be further apart!
    if !self.connected 
      q = $db.query("select session_key from sessions where id = (select session_id from devices where imei = '#{self.imei}')")
      q.callback do |res|
          self.session_key = res.fetch_row.first
          self.connected = true
          $channels[self.session_key] << JSON.generate({:event => 'connect', :type => 'tracker', :id => self.imei})
      end    
      q.errback do |res|
        puts res.inspect
        # Notify admin here that a device without session is trying to accomplish something, is there some
        # configuration missed somewhere? 
        puts "Something went horribly bad!!!"
      end  
      return 
    end
    
    puts "Received: #{data.inspect}"
    
    loc = {
      :longitude  => parse_lng(data[5]),
      :latitude   => parse_lat(data[6]),
      :altitude   => data[7],      
      :nos        => data[10].split(/\*/)[0],
      :hdop       => data[10].split(/\*/)[1],
      :tracker    => self.imei
    }
    
    self.latest_location  = loc
    self.hdop             = loc[:hdop]
    # Update tracker-status here dependent on whether we have a valid position or not!
    # This should use a better version of san-checking than this, perhaps we ought to validate it 
    # against previous locations to san-check if speed and location-difference matches to prevent
    # any iphone-like problems?

    if loc[:longitude] == "E0" || loc[:latitude] == "N0"
      # Update device status      
      # Move this into a single method!
      self.status = 2
      q = $db.query("update devices set status = 2 where imei = '#{loc[:tracker]}'")
      q.callback do |res|
        $channels[self.session_key] << JSON.generate({:event => 'status', :type => 'tracker', :id => self.imei, :status => 'no-fix'})        
      end      
      q.errback do |res|
        $channels[self.session_key] << JSON.generate({:event => 'error', :type => 'database', :message => "something nice about this error here?"})        
      end
    else    
      q = $db.query("insert into locations(longitude, latitude, altitude, nos, hdop, tracker_identifier, created_at) value('#{loc[:longitude]}','#{loc[:latitude]}', #{loc[:altitude]}, #{loc[:nos]}, #{loc[:hdop].gsub(/[^\d]/,"")}, '#{loc[:tracker].gsub(/$/, "")}', NOW());")
      
      q.callback do |res|
        # This is where we want to do hotzone-matching
        
        # Since this tracker just sent us valid coordinates, make sure it's flagged accordingly. 
        q2 = $db.query("update devices set status = 1 where imei = '#{loc[:tracker]}' and status != 1")
        q2.callback do |res|
          if self.status != 1          
            self.status = 1
            $channels[self.session_key] << JSON.generate({:event => 'status', :type => 'tracker', :id => self.imei, :status => 'ok'})                  
          end
        end
        q2.errback do |res|
          # Notify admin here, via some kind of error-management. Preferably sms, put push-notifications might be more
          # economical!
          logger.error "Error - could not update tracker-status in database!"
        end
      end
      
      # Clean up this error-callback, what's it used for? 
      q.errback{|res| puts "E:"+res.inspect}     
       
      # Merge current server-time into this response as well, so the GUI can update "latest response at" for the current device
      $channels[self.session_key] << JSON.generate({:event => 'location', :id => self.imei, :location => loc, :timestamp => Time.now.strftime("%y-%m-%d %H:%M")})
    end

  end
  
  def unbind
    # Here, send data on which tracker closed the connection as well - so we can update it in realtime
    $clients.delete(self.signature)
    query = $db.query("update devices set status = 0 where imei = '#{self.imei}'")
    query.callback do |res|
      $channels.each_pair do |key, value|
        value << JSON.generate({'event' => 'status', 'type' => 'tracker', 'id' => self.imei, 'status' => 'disconnect', 'channel' => key})   
      end
    end    
  end
  

  private
  
  def parse_lat(lat)
    fraction = ((lat[3..4].to_f * 60) + (lat[5..9].to_f*60.0)) / 3600.0
       sum = lat[1..2].to_f + fraction
       if(lat[0] == 'S')
         return -sum
       else 
         return sum
       end 

  end
  
  def parse_lng(lng)
    fraction = ((lng[4..5].to_f * 60) + (lng[6..10].to_f*60.0)) / 3600.0
    sum = lng[1..3].to_f + fraction
    if(lng[0] == 'W')
      return -sum
    else 
      return sum
    end

  end
    
end