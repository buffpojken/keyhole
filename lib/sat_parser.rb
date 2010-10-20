class SatParser < EventMachine::Connection
    
  attr_accessor :db, :imei, :latest_location, :hdop
    
  def post_init
    puts self.inspect
    @db = EventMachine::MySQL.new(:host => "localhost", :username => "root", :database => "keyhole_development")
    $channel << "{event:'connect', 'type':'tracker'}"
  end
  
  def receive_data(data)
    data = data.split(",")
    self.imei = data[0]
    loc = {
      :longitude  => parse_lng(data[5]),
      :latitude   => parse_lat(data[6]),
      :altitude   => data[7],      
      :nos        => data[10].split(/\*/)[0],
      :hdop       => data[10].split(/\*/)[1],
      :tracker    => get_tracker_id(data[0])
    }
    
    self.latest_location  = loc
    self.hdop             = loc[:hdop]
    
    q = @db.query("insert into locations(longitude, latitude, altitude, nos, hdop, tracker_id) value('#{loc[:longitude]}','#{loc[:latitude]}', #{loc[:altitude]}, #{loc[:nos]}, #{loc[:hdop]}, #{loc[:tracker]});")

    q.callback{|res| puts res.inspect}
    q.errback{|res| puts "E:"+res.inspect}

    $channel << JSON.generate(loc)
  end
  
  def unbind
    $channel << "GSAT closed connection"
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
  
  def get_tracker_id(imei)
    return 3
  end
  
end