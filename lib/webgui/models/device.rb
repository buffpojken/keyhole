# These are AR-models used by the WebGui.
class Device < ActiveRecord::Base

  belongs_to :session
  
  has_many :locations, :foreign_key => "tracker_identifier", :primary_key => "imei", :dependent => :destroy
  
  def clear!
    return self.locations.destroy_all
  end

  def latest_locations(limit = 10)
    if limit.nil? 
      return self.locations.find(:all, :order => "created_at desc")
    else      
      return self.locations.find(:all, :order => "created_at desc", :limit => limit)
    end
  end
  
end