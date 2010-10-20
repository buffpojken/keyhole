require 'rubygems'
require 'eventmachine'
require File.dirname(__FILE__) + '/sat_parser'
require File.dirname(__FILE__) + '/query_server'
require 'em-websocket'
require 'sinatra/base'
require 'thin'


EventMachine.run{
  
  # This can implement the AJAX-based query-server, without any need
  # of multiple servers. Or, it can just be an http-based reporting tool.
  class Querier < Sinatra::Base    
    get "/" do 
      return "This is Keyhole, with #{$clients.length} clients connected"
    end    
  end
  
  
  $channel = EM::Channel.new
  $clients = {}
    
  EventMachine::start_server "0.0.0.0", 5000, SatParser
  EventMachine::start_server "0.0.0.0", 5500, QueryServer
  
  # TODO - Make sure this reads config from a config-file instead of this weird thing!
  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => true) do |ws|
    ws.onopen{
      sid = $channel.subscribe { |msg| ws.send msg }      
      $clients[sid] = true
      ws.onmessage{|msg| $channel.push "Ninja!" }
      ws.onclose{
        $channel.unsubscribe(sid)
        $clients.delete(sid)
      }      
    }    
  end
  
  Querier.run!({:port => 3000})
  
}
