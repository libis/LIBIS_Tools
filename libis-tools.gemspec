# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'libis/tools/version'
require 'date'

Gem::Specification.new do |spec|
  spec.name          = 'libis-tools'
  spec.version       = ::Libis::Tools::VERSION
  spec.date          = Date.today.to_s

  spec.summary       = %q{LIBIS toolbox.}
  spec.description   = %q{Some tool classes for other LIBIS gems.}

  spec.authors       = ['Kris Dekeyser']
  spec.email         = ['kris.dekeyser@libis.be']
  spec.homepage      = 'https://github.com/Kris-LIBIS/LIBIS_Tools'
  spec.license       = 'MIT'

  spec.platform      = Gem::Platform::JAVA if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  spec.require_paths = ['lib']
  spec.has_rdoc = 'yard'

  spec.add_development_dependency 'bundler', '> 1.6'
  spec.add_development_dependency 'rake', '~> 10.3'
  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency 'term-ansicolor', '~> 1.6'
  spec.add_development_dependency 'equivalent-xml', '~> 0.5'
  spec.add_development_dependency 'awesome_print', '~> 1.6'

  spec.add_runtime_dependency 'nokogiri', '~> 1.6'
  spec.add_runtime_dependency 'gyoku',  '~> 1.3'
  spec.add_runtime_dependency 'nori', '~> 2.6'
  spec.add_runtime_dependency 'recursive-open-struct', '~> 1.0'
  spec.add_runtime_dependency 'parslet', '~> 1.7'
  spec.add_runtime_dependency 'simple_xlsx_reader', '~> 1.0'
  spec.add_runtime_dependency 'logging', '~> 2.0'
  spec.add_runtime_dependency 'concurrent-ruby', '~> 1.0'
  spec.add_runtime_dependency 'yard', '~> 0.9.11'
  spec.add_runtime_dependency 'roo', '~> 2.5'
  spec.add_runtime_dependency 'roo-xls', '~> 1.0'
  spec.add_runtime_dependency 'tty-prompt'
  spec.add_runtime_dependency 'tty-config'
  spec.add_runtime_dependency 'thor'

end
