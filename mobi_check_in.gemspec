# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mobi_check_in/version'

Gem::Specification.new do |gem|
  gem.name          = "mobi_check_in"
  gem.version       = MobiCheckIn::VERSION
  gem.authors       = ["David Kormushoff"]
  gem.email         = ["kormie@gmail.com"]
  gem.description   = %q{A check in gem}
  gem.summary       = %q{A way to check in}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
