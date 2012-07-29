require 'socket'
require 'rexml/document'

def get_random_imei
  "$342432423432"
end


t = TCPSocket.new('localhost', 5000)

doc = REXML::Document.new(File.read("gps_data.xml"))
data = []
doc.elements.each('locations/location') do |p|
  d = rand(10)
  imei = get_random_imei
  if true
    loc = "#{imei},432432,432432,23423432,32424,#{p.get_text('lng').to_s},#{p.get_text('lat').to_s},13,4,23.23,23*12"    
  else
    loc = "#{imei},432432,432432,23423432,32424,E0,N0,13,4,23.23,23*12"    
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

