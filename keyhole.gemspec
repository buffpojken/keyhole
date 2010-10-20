# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{keyhole}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["buffpojken"]
  s.date = %q{2010-10-20}
  s.default_executable = %q{keyhole}
  s.description = %q{longer description of your gem}
  s.email = %q{daniel@sykewarrior.com}
  s.executables = ["keyhole"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    "lib/em-websocket.rb",
     "lib/em-websocket/connection.rb",
     "lib/em-websocket/debugger.rb",
     "lib/em-websocket/handler.rb",
     "lib/em-websocket/handler75.rb",
     "lib/em-websocket/handler76.rb",
     "lib/em-websocket/handler_factory.rb",
     "lib/em-websocket/websocket.rb",
     "lib/keyhole.rb",
     "lib/query_server.rb",
     "lib/sat_parser.rb"
  ]
  s.homepage = %q{http://github.com/buffpojken/keyhole}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{one-line summary of your gem}
  s.test_files = [
    "test/helper.rb",
     "test/test_keyhole.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    else
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    end
  else
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
  end
end

