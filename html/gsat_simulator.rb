require 'socket'
require 'rexml/document'



t = TCPSocket.new('localhost', 5000)

doc = REXML::Document.new(File.read("gps_data.xml"))
data = []
doc.elements.each('locations/location') do |p|
  d = rand(10)
  if d >= 4
    loc = "$342432423432,432432,432432,23423432,32424,#{p.get_text('lng').to_s},#{p.get_text('lat').to_s},13,4,23.23,23*12"    
  else
    loc = "$342432423432,432432,432432,23423432,32424,0,0,13,4,23.23,23*12"    
  end
  data.push(loc)
end

current_index = 0
puts data.length

while(true) do
  puts "Will sleep for 5 seconds"
  sleep 5
  t.print(data[current_index])
  current_index += 1  
end

