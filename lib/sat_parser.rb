class SatParser < EventMachine::Connection
    
  def post_init
    puts "GSAT connected"
  end
  
  def receive_data(data)
    puts "Data received..."
    puts data.inspect
    $channel << data
  end
  
  def unbind
    $channel << "GSAT closed connection"
  end
  
end