class CreateDevices < ActiveRecord::Migration
  
  def self.up
    create_table :devices do |t|
      t.string    :name
      t.integer   :session_id
      t.string    :imei
      t.string    :color
      t.integer   :status
      t.datetime  :latest_update
      t.timestamps
    end
  end
  
  def self.down
    drop_table 'devices'
  end
  
end