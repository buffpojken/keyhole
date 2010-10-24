# These are AR-models used by the WebGui.
class Device < ActiveRecord::Base
  
  has_many :locations, :foreign_key => "tracker_identifier", :primary_key => "imei"
  
  before_create :generate_color
  
  def latest_locations(limit = 10)
    return self.locations.find(:all, :order => "created_at desc", :limit => limit)
  end
  
  private
  
  def generate_color
    self.color = "#"+"%06x" % (rand * 0xffffff)
    # Debug-code, must be removed, otherwise all models will have the test-trackers imei
    self.imei = "$342432423432"
  end
  
end

class Location < ActiveRecord::Base
  
  belongs_to :device, :primary_key => :imei, :foreign_key => :tracker_identifier, :class_name => "Device"
  
end