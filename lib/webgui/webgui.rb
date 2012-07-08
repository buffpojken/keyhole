require 'rubygems'
require 'sinatra/base'
require 'sinatra/content_for'
require 'sinatra/assetpack'
require 'rack-flash'
require 'active_record'
require 'rest-client'
require 'mysql2'
Dir.glob(File.dirname(__FILE__)+"/models/*.rb").each do |fi|
  require fi
end
Dir.glob(File.dirname(__FILE__)+"/lib/*.rb").each do |fi|
  require fi
end

class WebGui < Sinatra::Base    
  use Rack::Session::Cookie
  use Rack::Flash
  set :root, File.dirname(__FILE__)
  set :public_folder, Proc.new { File.join(root, 'views/public')}

  set :twilio_sid, "AC7aad28b36ad141399cd3057da04103cc"
  set :twilio_token, "b26da84950d227342f7545d026db51c3"

  register Sinatra::ContentFor
  
  # helpers
  helpers Sinatra::ContentFor
  helpers Helpers
  
  before '/map*' do 
    authorize!
  end
  
  before '/configure*' do 
    authorize!(:require_admin => true)
  end     
  
  after do
    ActiveRecord::Base.clear_active_connections!
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
    if @session.update_attributes(params[:session])
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
    redirect to('/configure')
  end
  
  get '/configure/session/:id/layers' do 
    @session  = Session.find(params[:id])
    @layers   = Layer.find(:all, :conditions => ["session_id is null"])
    erb :layers
  end

  get '/configure/session/:id/layer/:layer_id' do 
    @session  = Session.find(params[:id])
    layer     = Layer.find(params[:layer_id])
    unless @session.layers << layer && @session.save
      flash[:error] = "Could not add layer, try again!"
    end
    redirect back
  end
  
  get '/configure/layer/:id/remove' do 
    layer = Layer.find(params[:id])
    if layer.update_attribute(:session_id, nil)
      flash[:notice] = "Layer deactivated"
    else
      flash[:error] = "Could not deactivate layer"
    end
    redirect back
  end
  
  get '/configure/layer/:id/destroy' do 
    if Layer.destroy(params[:id])
      flash[:notice] = "Layer deleted"
    else
      flash[:error] = "Layer could not be deleted, try again!"
    end
    redirect back
  end
  
  get '/configure/layer/new' do 
    erb :new_layer
  end
  
  post '/configure/layer/new' do 
    layer = Layer.create(params[:layer])
    if layer && layer.errors.empty? 
      redirect to('/configure')
    else
      flash[:error] = "Could not add layer, try again!"
      erb :new_layer
    end
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
    authorize!
    @session = @current_user.sessions.find_by_id(params[:session_id])
    if @session
      @in_map = true
      erb :map
    else
      flash[:error] = "Not your session, punk!"
      redirect '/account'
    end
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