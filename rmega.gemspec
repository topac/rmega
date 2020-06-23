# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rmega/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["topac"]
  gem.email         = ["topac@users.noreply.github.com"]
  gem.description   = %q{mega.nz ruby api}
  gem.summary       = %q{mega.nz ruby api}
  gem.homepage      = Rmega::HOMEPAGE

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rmega"
  gem.require_paths = ["lib"]
  gem.version       = Rmega::VERSION
  gem.license       = 'MIT'
  gem.required_ruby_version = '>= 1.9.3'

  gem.add_dependency "pbkdf2-ruby"

  gem.add_development_dependency "pry"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rake"
end
