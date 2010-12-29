require 'rubygems'
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
    @sessions = Session.find(:all)
    erb :configure
  end
  
  get '/configure/session/new' do 
    authorize!
    erb :new_session
  end

  post '/configure/session/new' do 
    @session = Session.create(params[:session].merge({:user_id => @current_user.id}))
    if @session && @session.errors.empty?
      redirect '/configure'
    else
      flash[:error] = "Could not create session"
      redirect '/configure/session/new'
    end
  end

  get '/configure/session/:id/edit' do 
    authorize!
    @session = Session.find(params[:id])
    @devices = Device.find(:all, :conditions => ["session_id is null"])
    erb :edit_session
  end

  post '/configure/session/:id/edit' do 
    authorize!
    @session = Session.find(params[:id])
    if @session.update_attributes(params[:session]) && @session.set_devices(params[:devices])
      redirect '/configure'
    else
      flash[:error] = "Could not update session-data"
      redirect "/configure/session/#{@session.id}/edit"
    end
  end
  
  get '/configure/session/:id/destroy' do 
    authorize!
    @session = Session.find(params[:id])
    if @session && @session.destroy
      flash[:notice] = "Session removed"
    else
      flash[:error] = "Could not remove session"
    end    
    redirect '/configure'
  end
  
  get "/configure/device/new" do 
    erb :new_device
  end
  
  post '/configure/device/new' do 
    device = Device.create(params[:device])
    if device && device.errors.empty?
      flash[:notice] = "Device created"
      redirect '/configure'
    else
      flash[:error] = "Could not create new device"
    end
  end

  get '/configure/device/:id/disconnect' do 
    device = Device.find(params[:id])
    session_id = device.session_id
    device.update_attribute(:session_id, nil)
    redirect "/configure/session/#{session_id}/edit"
  end
  
  get '/configure/device/:id/connect/:session_id' do 
    device = Device.find(params[:id])
    device.update_attribute(:session_id, params[:session_id])
    redirect "/configure/session/#{params[:session_id]}/edit"    
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