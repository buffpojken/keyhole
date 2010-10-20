require 'socket'

begin
  t = TCPSocket.new('94.247.168.97', 5000)
rescue 
  puts "error: #{$!}"
else
  t.print "negerkung"
  puts t.gets(nil)
  t.close
end