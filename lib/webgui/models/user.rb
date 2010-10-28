require 'digest/sha1'
class User < ActiveRecord::Base
  attr_accessor :passsword_confirmation

  has_many :sessions

  def latest_session
    return self.sessions.find(:first, :order => "created_at desc")
  end


  # AUTHENTICATION
  
  def password
    @password
  end
  
  def password=(pwd)
    @password = pwd
    return if (pwd.nil? || pwd == "")
    create_new_salt
    self.crypted_password = User.encrypted_password(self.password, self.salt)    
  end  
    
  def self.encrypted_password(password, salt)
    Digest::SHA1.hexdigest(password+"wibble"+salt)
  end
  
  def self.authenticate(login, password)
    user = self.find_by_login(login)
    if user
      unless user.crypted_password == encrypted_password(password, user.salt)
        user = nil
      end
    end
    user
  end
  
  # END OF AUTHENTICATION
  
  
  private
  
  def create_new_salt
    self.salt = self.object_id.to_s+rand.to_s
  end
  
end