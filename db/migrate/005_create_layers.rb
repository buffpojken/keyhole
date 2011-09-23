class CreateLayers< ActiveRecord::Migration
  
  def self.up
    create_table :layers do |t|
      t.string    :name
      t.string    :url
      t.string    :session_id
      t.timestamps
    end
  end
  
  def self.down
    drop_table "layers"
  end
  
end