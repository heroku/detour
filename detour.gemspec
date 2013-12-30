# coding: utf-8
$:.push File.expand_path("../lib", __FILE__)

require "detour/version"

Gem::Specification.new do |spec|
  spec.name          = "detour"
  spec.version       = Detour::VERSION
  spec.authors       = ["Jonathan Clem"]
  spec.email         = ["jonathan@heroku.com"]
  spec.summary       = %q{Rollouts (feature flags) for Rails.}
  spec.description   = %q{Rollouts (feature flags) for Rails.}
  spec.homepage      = "https://github.com/heroku/detour"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(spec)/})

  spec.required_ruby_version = ">= 1.9.3"

  spec.add_dependency "rails", "~> 3.2.16"

  spec.add_development_dependency "capybara"
  spec.add_development_dependency "database_cleaner", "~> 1.2.0"
  spec.add_development_dependency "factory_girl_rails"
  spec.add_development_dependency "pry-nav"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "selenium-webdriver"
  spec.add_development_dependency "shoulda-matchers"
  spec.add_development_dependency "sqlite3-ruby"
  spec.add_development_dependency "yard"
end
