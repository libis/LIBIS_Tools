require 'bundler/setup'
Bundler.setup

require 'rspec'
require 'libis-tools'

require 'codeclimate-test-reporter'
::CodeClimate::TestReporter.start

require 'coveralls'
Coveralls.wear!
