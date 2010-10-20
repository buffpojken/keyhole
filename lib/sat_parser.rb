class SatParser < EventMachine::Connection
    
  attr_accessor :db  
    
  def post_init
    puts self.inspect
    @db = EventMachine::MySQL.new(:host => "localhost", :username => "root", :database => "keyhole_development")
    $channel << "{event:'connect', 'type':'tracker'}"
  end
  
  def receive_data(data)
    puts "Data received..."
    puts data.inspect
    q = @db.query("insert into locations(latitude, longitude) value('ninja', 'neger');")
    q.callback{|res| puts res.inspect}
    q.errback{|res| puts "E:"+res.inspect}
    $channel << data
  end
  
  def unbind
    $channel << "GSAT closed connection"
  end
  
end