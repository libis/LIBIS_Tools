# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'libis/tools/version'

Gem::Specification.new do |spec|
  spec.name          = 'LIBIS_Tools'
  spec.version       = ::LIBIS::Tools::VERSION
  spec.date          = Date.today.to_s

  spec.summary       = %q{LIBIS toolbox.}
  spec.description   = %q{Some tool classes for other LIBIS gems.}

  spec.authors       = ['Kris Dekeyser']
  spec.email         = ['kris.dekeyser@libis.be']
  spec.homepage      = 'https://github.com/Kris-LIBIS/LIBIS_Tools'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'

  spec.add_runtime_dependency 'backports'
  spec.add_runtime_dependency 'savon', '~> 2.0'
  spec.add_runtime_dependency 'rest_client'
  spec.add_runtime_dependency 'write_xlsx'
  spec.add_runtime_dependency 'awesome_print'
  spec.add_runtime_dependency 'settingslogic'

end
