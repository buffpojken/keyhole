class CreateUsers < ActiveRecord::Migration

  def self.up
    create_table :users do |t|
      t.string    :login
      t.string    :email
      t.string    :salt
      t.string    :crypted_password
      t.boolean   :admin, :default => false      
    end
  end
  
  def self.down
    drop_table "users"
  end


end