
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "kimurai/version"

Gem::Specification.new do |spec|
  spec.name          = "kimurai"
  spec.version       = Kimurai::VERSION
  spec.authors       = ["Victor Afanasev"]
  spec.email         = ["vicfreefly@gmail.com"]

  spec.summary       = "Modern web scraping framework written in Ruby and based on Capybara/Nokogiri"
  spec.homepage      = "https://github.com/vifreefly/kimuraframework"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = "kimurai"
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.5.0"

  spec.add_dependency "thor"
  spec.add_dependency "cliver"
  spec.add_dependency "activesupport"
  spec.add_dependency "murmurhash3"
  spec.add_dependency "nokogiri"

  spec.add_dependency "capybara", ">= 2.15", "< 4.0"
  spec.add_dependency "capybara-mechanize"
  spec.add_dependency "poltergeist"
  spec.add_dependency "selenium-webdriver"

  spec.add_dependency "headless"
  spec.add_dependency "pmap"

  spec.add_dependency "addressable"
  spec.add_dependency "whenever"

  spec.add_dependency "rbcat", "~> 0.2"
  spec.add_dependency "pry"

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
