require 'sinatra/base'
require 'sinatra/content_for'
require 'rack-flash'
require 'active_record'
require 'mysql2'
Dir.glob(File.dirname(__FILE__)+"/models/*.rb").each do |fi|
  require fi
end
Dir.glob(File.dirname(__FILE__)+"/lib/*.rb").each do |fi|
  require fi
end

# This can implement the AJAX-based query-server, without any need
# of multiple servers. Or, it can just be an http-based reporting tool.
# This should be moved into it's own folder-setup, since this most probably
# will server the actual GUI as well? 



class WebGui < Sinatra::Base    
  use Rack::Session::Cookie
  use Rack::Flash
  register Sinatra::ContentFor
  
  set :root, File.dirname(__FILE__)
  set :public, Proc.new { File.join(root, 'views/public')}
  
  # helpers
  helpers Sinatra::ContentFor
  helpers Helpers
  
  # callback
  
  before '/map*' do 
    authorize!
  end
  
  before '/configure*' do 
    authorize!(:require_admin => true)
  end  
  
  # code

  
  get "/" do
    erb :frontpage
  end
  
  get '/account' do 
    authorize!
    @latest_session = @current_user.latest_session
    erb :account
  end
  
  get "/configure" do 
    @devices = Device.find(:all)    
    erb :configure
  end
  
  get "/configure/device/new" do 
    erb :new_device
  end
  
  get '/session/new' do 
    authorize!
    erb :new_session
  end
  
  get "/map/:session_id" do
    @session = Session.find(params[:session_id])    
    erb :map
  end
  
  # Authentication/Session/Login
  
  post "/" do 
    user = User.authenticate(params[:login], params[:password])
    if user
      session[:user_id] = user.id
      redirect '/account'
    else
      flash[:error] = "data non valet"
      erb :frontpage
    end
  end
 
  get '/logout' do 
    logout!
    redirect "/"
  end

end


ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql2',
  :database => 'keyhole_development', 
  :username => 'root', 
  :password => ''
)