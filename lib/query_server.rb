# QueryServer responds to telnet-calls on its designated port, and responds
# with things...
class QueryServer < EventMachine::Connection
  def post_init
    send_data "#{$clients.length} clients connected"
  end
  
  def receive_data(data)
    send_data "#{$clients.length} clients connected"
    close_connection if data =~ /quit/i
  end
  
end