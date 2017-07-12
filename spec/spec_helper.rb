# require 'codeclimate-test-reporter'
# ::CodeClimate::TestReporter.start

if !defined?(RUBY_ENGINE) || RUBY_ENGINE != 'jruby'
  require 'coveralls'
  Coveralls.wear!
end

# noinspection RubyResolve
require 'bundler/setup'
# noinspection RubyResolve
Bundler.setup

require 'rspec'
require 'libis-tools'

# RSpec.configure do |config|
#   original_stderr = $stderr
#   original_stdout = $stdout
#   config.before(:all) do
#     # Redirect stderr and stdout
#     $stderr = File.open(File::NULL, 'w')
#     $stdout = File.open(File::NULL, 'w')
#   end
#   config.after(:all) do
#     $stderr = original_stderr
#     $stdout = original_stdout
#   end
# end