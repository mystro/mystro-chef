$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "mystro-chef/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "mystro-chef"
  s.version     = Mystro::Chef::Version::STRING
  s.authors     = ["Shawn Catanzarite"]
  s.email       = ["me@shawncatz.com"]
  s.homepage    = "https://github.com/mystro"
  s.summary     = "mystro chef integration plugin"
  s.description = "mystro chef integration plugin"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.14"
  s.add_dependency "chef", "11.8.2"
  s.add_dependency "ridley", "2.4.2"

  #s.add_development_dependency "sqlite3"
end
