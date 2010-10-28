require 'digest/sha1'
class Session < ActiveRecord::Base
  
  has_many :devices
  
  before_create :generate_session_key
  
  private
  
  def generate_session_key
    self.session_key = Digest::SHA1.hexdigest(self.object_id.to_s + Time.now.to_s)
  end
  
end