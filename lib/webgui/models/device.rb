# These are AR-models used by the WebGui.
class Device < ActiveRecord::Base

  belongs_to :session
  
  has_many :locations, :foreign_key => "tracker_identifier", :primary_key => "imei", :dependent => :destroy
  
  before_create :generate_color
  
  def latest_locations(limit = 10)
    return self.locations.find(:all, :order => "created_at desc", :limit => limit)
  end
  
  private
  
  def generate_color
    self.color = "#"+"%06x" % (rand * 0xffffff)
  end
  
end