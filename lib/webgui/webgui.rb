require 'sinatra/base'
require 'active_record'
require 'mysql2'
require File.dirname(__FILE__)+"/models"
# This can implement the AJAX-based query-server, without any need
# of multiple servers. Or, it can just be an http-based reporting tool.
# This should be moved into it's own folder-setup, since this most probably
# will server the actual GUI as well? 



class WebGui < Sinatra::Base    

  set :root, File.dirname(__FILE__)
  set :public, Proc.new { File.join(root, 'views/public')}

  get "/" do
    # TODO - Scope this on current session and so weiter...
    @devices = Device.find(:all)
    erb :index
  end   
  
  get "/config" do 
    @devices = Device.find(:all)    
    erb :config
  end

end


ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql2',
  :database => 'keyhole_development', 
  :username => 'root', 
  :password => ''
)