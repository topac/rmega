# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rmega/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Daniele Molteni"]
  gem.email         = ["dani.m.mobile@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rmega"
  gem.require_paths = ["lib"]
  gem.version       = Rmega::VERSION

  gem.add_development_dependency "pry"
  gem.add_development_dependency "rspec"
  gem.add_dependency "execjs"
end
