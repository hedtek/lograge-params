$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "lograge-params/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "lograge-params"
  s.version     = LogrageParams::VERSION
  s.authors     = ["Hedtek Ltd.", "David Workman"]
  s.email       = ["gems@hedtek.com"]
  s.homepage    = "https://github.com/hedtek/lograge-params"
  s.summary     = "Serialises parameters out as part of lograge formatting"
  s.description = "Serialises parameters out as part of lograge formatting"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.1"
  s.add_dependency "lograge"
  s.add_dependency "useragent"

  s.add_development_dependency "sqlite3"
end
