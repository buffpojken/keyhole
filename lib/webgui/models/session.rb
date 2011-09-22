require 'digest/sha1'
class Session < ActiveRecord::Base
  
  has_many :devices
  has_many :layers
  
  before_create :generate_session_key
  before_destroy :release_devices
  
  def set_devices(device_data)
    device_data.each_pair do |device_id, status|
      device = Device.find(device_id)
      device.update_attribute(:session_id, self.id)
    end
    return true
  end
  
  private
  
  def generate_session_key
    self.session_key = Digest::SHA1.hexdigest(self.object_id.to_s + Time.now.to_s)
  end
  
  def release_devices
    self.devices.each do |device|
      device.update_attribute(:session_id, nil)
    end
  end
  
end