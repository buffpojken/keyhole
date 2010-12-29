require 'rubygems'
require 'rake'
# This is only to support migrations, my belief is that someone already has split this out
# into a separate class in Rails 3! .ds
require 'active_record'
require 'yaml'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "keyhole"
    gem.summary = %Q{one-line summary of your gem}
    gem.description = %Q{longer description of your gem}
    gem.email = "daniel@sykewarrior.com"
    gem.homepage = "http://github.com/buffpojken/keyhole"
    gem.authors = ["buffpojken"]
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    gem.files = Dir['lib/**/**']
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "keyhole #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


# Add custom support for migrations, since no sane person manages to keep the 
# database current in regards to scheme by hand .ds
desc "Migrate the database through scripts in db/migrate. Target specific version with VERSION=x"
task :migrate => :environment do  
  ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
end

desc "Runs the Ruby-code in db/seed.rb with the environment loaded, perfect for seeding the database!"
task :seed => :environment do 
  load File.join(*%w[db seed.rb])
end

task :environment do
  ActiveRecord::Base.establish_connection(YAML::load(File.open('config/database.yml')))
  # Load the environment used by the webgui
  Dir.glob(File.join(*%w[ lib webgui models *.rb ])).each do |fi|
    require fi
  end  
end
