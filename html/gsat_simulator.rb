require 'socket'

a = "$IMEI NUMBER,Status,GPS_fix,GPSDate, GPSLocalTime,Longitude,Latitude,Altitude,speed,heading,number of satellites in use*HDOP !"
b = "$123456564432,3,1,201004130343,14:32:23,59.34324,18.452r252,450,1,45,45!"


t = TCPSocket.new('127.0.0.1', 5000)

while(true) do
  r = rand(5)
  puts "Will sleep for #{r} seconds"
  sleep r
  
  t.print(b)
  
end