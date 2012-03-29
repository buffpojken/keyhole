module Helpers
  def logged_in?
    return !!current_user
  end

  def current_user
     unless session[:user_id].nil?
       @current_user ||= User.find_by_id(session[:user_id])
     else
       return nil
     end
  end  
  
  # Store the given user id in the session.
  def current_user=(new_user)
    session[:user_id] = new_user ? new_user.id : nil
    @current_user = new_user || false
  end
  
  def authorize!(options = {})
    options = {:path => "/"}.merge(options)
    unless logged_in?
      flash[:error] = "Please log in!"
      redirect options[:path]
    else
      if options[:require_admin] 
        unless @current_user.admin?
          flash[:error] = "You are not admin."
          redirect options[:path] || "/account"
        end
      end      
    end
  end
  
  def logout!
    session[:user_id], @current_user = nil, nil
  end
  
  def mark_by_status(status)
    if status == 0
      'offline'
    elsif status == 2
      'no-fix'
    else
      ''
    end
  end
end