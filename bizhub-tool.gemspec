$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "bizhub-tool/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "bizhub-tool"
  s.version     = BizhubTool::VERSION
  s.authors     = ["Adam Saegebarth"]
  s.email       = ["adams@synapse.com"]
  s.homepage    = "https://github.com/synapsepd"
  s.summary     = "A client for the Konica/Minolta Bizhub OpenAPI"
  s.description = "Description of BizhubTool."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]
  spec.add_development_dependency 'nori', '~> 1.1.0', '>= 1.1.0'
end
