require 'rubygems'
require 'eventmachine'
require File.dirname(__FILE__) + '/sat_parser'
require File.dirname(__FILE__) + '/query_server'
require File.dirname(__FILE__) + '/webgui/webgui'
require File.dirname(__FILE__) + '/em-websocket/em-websocket'
require 'thin'
require 'em-mysqlplus'
require 'json'

if $0 == __FILE__
  # This will differentiate between running this as the gem, and running in debug-mode! 
  # Use this to set debug-flags, change the coordinate-parsing and stuff like that!
end



EventMachine.run{
    
  $db = EventMachine::MySQL.new(:host => "localhost", :username => "root", :database => "keyhole_development")
  # When running multiple 
  $channel    = EM::Channel.new
  $clients    = {}
  $webclients = {}
  
  
  EventMachine::start_server "0.0.0.0", 5000, SatParser
  EventMachine::start_server "0.0.0.0", 5500, QueryServer
  
  # TODO - Make sure this reads config from a config-file instead of this weird thing!
  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => true) do |ws|
    ws.onopen{
      sid = $channel.subscribe { |msg| ws.send msg }      
      $webclients[sid] = true

      ws.onmessage do |msg|
        # Here, we should have some kind of command-parser, to allow the gui to query for stuff using the 
        # sockets? Or should that perhaps be done using AJAX?
        $channel << "ninja!"
      end

      ws.onclose{
        $channel.unsubscribe(sid)
        $webclients.delete(sid)
      }      
    }    
  end
  
  # This class is a subclass to Sinatra-base, check /webgui for code, models and views
  WebGui.run!({:port => 3000})
  
}

