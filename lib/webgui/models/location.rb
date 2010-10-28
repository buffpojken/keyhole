class Location < ActiveRecord::Base
  
  belongs_to :device, :primary_key => :imei, :foreign_key => :tracker_identifier, :class_name => "Device"
  
end