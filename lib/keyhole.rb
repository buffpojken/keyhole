require 'rubygems'
require 'eventmachine'
require File.dirname(__FILE__) + '/sat_parser'
require File.dirname(__FILE__) + '/query_server'
require File.dirname(__FILE__) + '/webgui/webgui'
require File.dirname(__FILE__) + '/em-websocket/em-websocket'
require 'thin'
require 'em-mysqlplus'
require 'json'




EventMachine.run{
    
  $db = EventMachine::MySQL.new(:host => "localhost", :username => "bongo", :password => "ninjamagick", :database => "keyhole_development")
  # When running multiple 
  $channels    = {}
  $clients    = {}
  $webclients = {}
  
  # Add a global channel for communicating with -all- connected clients!
  $channels["global"] = EventMachine::Channel.new
  
  # TODO - Make sure this reads config from a config-file instead of this weird thing!
  ws_server = EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => true) do |ws|
    ws.onopen{|req|
      # Attach this socket to the correct channel.      
      path = req["path"].gsub("/", "")
      if $channels[path].nil?
        $channels[path] = EventMachine::Channel.new
      end
      
      sid = $channels[path].subscribe { |msg| ws.send msg }      
      gid = $channels['global'].subscribe{ |msg| ws.send msg }
      $webclients[sid] = true

      ws.onmessage do |msg|
      # Here, we should have some kind of command-parser, to allow the gui to query for stuff using the 
      # sockets? Or should that perhaps be done using AJAX?
       $channels[path] << "ninja!"
      end

      ws.onclose{
        $channels[path].unsubscribe(sid)
        $channels['global'].unsubscribe(gid)
        $webclients.delete(sid)
      }      

    }
  end
  
  EventMachine::start_server "0.0.0.0", 5000, SatParser
  EventMachine::start_server "0.0.0.0", 5500, QueryServer
    
  # This class is a subclass to Sinatra-base, check /webgui for code, models and views
  WebGui.run!({:port => 3000})
  
}

