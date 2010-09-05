require 'socket'

begin
  t = TCPSocket.new('127.0.0.1', 5500)
rescue 
  puts "error: #{$!}"
else
  t.print "negerkung"
  puts t.gets(nil)
  t.close
end