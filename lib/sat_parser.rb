class SatParser < EventMachine::Connection
    
  attr_accessor :db  
    
  def post_init
#    $clients(self)
    puts self.inspect
    db = EventMachine::MySQL.new(:host => "localhost", :username => "root", :database => "keyhole_development")
    $channel << "{event:'connect', 'type':'tracker'}"
  end
  
  def receive_data(data)
    puts "Data received..."
    puts data.inspect
    db.query("insert into locations(latitude, longitude) value('ninja', 'neger');")
    $channel << data
  end
  
  def unbind
    $channel << "GSAT closed connection"
  end
  
end