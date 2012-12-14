# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cronie/version'

Gem::Specification.new do |gem|
  gem.name          = "cronie"
  gem.version       = Cronie::VERSION
  gem.authors       = ["labocho"]
  gem.email         = ["labocho@penguinlab.jp"]
  gem.description   = %q{Cronie runs task by cron-compatible schedule}
  gem.summary       = %q{Cronie runs task by cron-compatible schedule}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rspec", "~> 2.12.0"
  gem.add_development_dependency "debugger", "~> 1.2.0"
end
