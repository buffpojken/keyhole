class SatParser < EventMachine::Connection
    
  attr_accessor :db, :imei, :latest_location, :hdop
    
  def post_init
    $clients[self.signature] = true
    @db = EventMachine::MySQL.new(:host => "localhost", :username => "root", :database => "keyhole_development")
    # Here, check if the device exists - if yes, update it to online and defer the response, 
    # if not - notify the GUI that an unknown tracker has tried to connect, did you forget to add it to the session?
    $channel << "{event:'connect', 'type':'tracker'}"
  end
  
  
  def receive_data(data)
    puts data.inspect
    
    data = data.split(",")
    self.imei = data[0]
    
    loc = {
      :longitude  => parse_lng(data[5]),
      :latitude   => parse_lat(data[6]),
      :altitude   => data[7],      
      :nos        => data[10].split(/\*/)[0],
      :hdop       => data[10].split(/\*/)[1],
      :tracker    => data[0]
    }
    
    self.latest_location  = loc
    self.hdop             = loc[:hdop]
    # Update tracker-status here dependent on whether we have a valid position or not!
    # This should use a better version of san-checking than this, perhaps we ought to validate it 
    # against previous locations to san-check if speed and location-difference matches to prevent
    # any iphone-like problems?
    if loc[:longitude] == "0" || loc[:latitude] == "0"
      # Update device status      
      q = @db.query("update devices set status = 2 where imei = '#{loc[:tracker]}'")
      q.callback do |res|
        $channel << JSON.generate({:event => 'status-change', :type => 'tracker', :tracker => '3', :status => 'no-fix'})        
      end      
      q.errback do |res|
        $channel << JSON.generate({:event => 'error', :type => 'database', :message => "something nice about this error here?"})        
      end
    else    
      q = @db.query("insert into locations(longitude, latitude, altitude, nos, hdop, tracker_identifier) value('#{loc[:longitude]}','#{loc[:latitude]}', #{loc[:altitude]}, #{loc[:nos]}, #{loc[:hdop].gsub(/[^\d]/,"")}, '#{loc[:tracker]}');")

      q.callback do |res|
        q2 = @db.query("update devices set status = 1 where imei = '#{loc[:tracker]}'")
      end
      
      q.errback{|res| puts "E:"+res.inspect}     
       
      # Merge current server-time into this response as well, so the GUI can update "latest response at" for the current device
      $channel << JSON.generate(loc)
    end

  end
  
  def unbind
    # Here, send data on which tracker closed the connection as well - so we can update it in realtime
    $channel << JSON.generate({'event' => 'disconnect', 'type' => 'tracker', 'id' => 3})
  end
  

  private
  
  def parse_lat(lat)
    # fraction = ((lat[3..4].to_f * 60) + (lat[5..9].to_f*60.0)) / 3600.0
    # sum = lat[1..2].to_f + fraction
    # if(lat[0] == 'S')
    #   return -sum
    # else 
    #   return sum
    # end 
    return lat
  end
  
  def parse_lng(lng)
    # fraction = ((lng[4..5].to_f * 60) + (lng[6..10].to_f*60.0)) / 3600.0
    # sum = lng[1..3].to_f + fraction
    # if(lng[0] == 'W')
    #   return -sum
    # else 
    #   return sum
    # end
    return lng
  end
    
end