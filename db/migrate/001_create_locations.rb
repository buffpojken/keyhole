class CreateLocations < ActiveRecord::Migration
  
  def self.up
    create_table :locations do |t|
      t.string    :latitude 
      t.string    :longitude 
      t.string    :tracker_identifier
      t.string    :altitude
      t.integer   :nos 
      t.string    :hdop
      t.timestamps
    end    
  end
  
  def self.down
    drop_table 'locations'
  end
  
end