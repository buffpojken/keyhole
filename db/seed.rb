user = User.create({
  :login => "buffpojken", 
  :password => "ninjamagick", 
  :admin => true  
})

session = user.sessions.create({
  :name => "Testsession 1"
})

device = session.devices.create({
  :name => "Thor", 
  :imei => "342432423432", 
  :color => "#d3f62f" 
})