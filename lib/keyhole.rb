require 'rubygems'
require 'eventmachine'
require File.dirname(__FILE__) + '/sat_parser'
require File.dirname(__FILE__) + '/query_server'
require 'em-websocket'
require 'sinatra/base'
require 'thin'
require 'em-mysqlplus'
require 'json'


EventMachine.run{
  
  # This can implement the AJAX-based query-server, without any need
  # of multiple servers. Or, it can just be an http-based reporting tool.
  # This should be moved into it's own folder-setup, since this most probably
  # will server the actual GUI as well? 
  class Querier < Sinatra::Base    
    get "/" do 
      return "This is Keyhole, with #{$clients.length} trackers and #{$webclients.length} webclients connected."
    end    
  end
  
  
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
  
  Querier.run!({:port => 3000})
  
}
