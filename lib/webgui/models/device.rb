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
    a = RestClient.post "http://young-fire-8657.heroku.com/", {
      :file => File.new(File.join('webgui', 'views', 'public', 'images', 'blue_dot_circle.png'), 'rb'), 
      :hex  => "#"+self.color
    }
    file = File.open(File.join('webgui', 'views', 'public', 'images', self.color + '_marker.png'), 'w+')
    file.puts a
    file.close
  end
  
end