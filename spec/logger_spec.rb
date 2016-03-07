# encoding: utf-8
require_relative 'spec_helper'
require 'libis/tools/config'
require 'libis/tools/logger'

describe 'Logger' do

  class TestLogger
    include ::Libis::Tools::Logger
  end

  before :each do
    ::Libis::Tools::Config.logger.appenders =
        ::Logging::Appenders.string_io('StringIO', layout: ::Libis::Tools::Config.get_log_formatter)
    ::Libis::Tools::Config.logger.level = :all
  end

  let(:test_logger) { TestLogger.new }
  let(:logoutput) { ::Libis::Tools::Config.logger.appenders.last.sio }

  let(:timestamp_regex) { '\[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3} #\d+\.\d+\]' }

  context 'with default log configuration' do

    it 'should log debug output' do
      test_logger.debug 'Debug message'
      output = logoutput.string.lines.map(&:chomp)
      expect(output.size).to eq 1
      expect(output.last).to match /^D, #{timestamp_regex} DEBUG : Debug message$/
    end

    it 'should log info output' do
      test_logger.info 'Info message'
      output = logoutput.string.lines.map(&:chomp)
      expect(output.size).to eq 1
      expect(output.last).to match /^I, #{timestamp_regex}  INFO : Info message$/
    end

    it 'should log warning output' do
      test_logger.warn 'Warning message'
      output = logoutput.string.lines.map(&:chomp)
      expect(output.size).to eq 1
      expect(output.last).to match /^W, #{timestamp_regex}  WARN : Warning message$/
    end

    it 'should log error output' do
      test_logger.error 'Error message'
      output = logoutput.string.lines.map(&:chomp)
      expect(output.size).to eq 1
      expect(output.last).to match /^E, #{timestamp_regex} ERROR : Error message$/
    end

    it 'should log fatal output' do
      test_logger.fatal 'Fatal message'
      output = logoutput.string.lines.map(&:chomp)
      expect(output.size).to eq 1
      expect(output.last).to match /^F, #{timestamp_regex} FATAL : Fatal message$/
    end

    it 'should be quiet when asked to' do
      ::Libis::Tools::Config.logger.level = :error

      test_logger.debug 'Debug message'
      output = logoutput.string.lines.map(&:chomp)
      # noinspection RubyResolve
      expect(output).to be_empty

      test_logger.info 'Info message'
      output = logoutput.string.lines.map(&:chomp)
      # noinspection RubyResolve
      expect(output).to be_empty

      test_logger.warn 'Warn message'
      output = logoutput.string.lines.map(&:chomp)
      # noinspection RubyResolve
      expect(output).to be_empty

      test_logger.error 'Error message'
      output = logoutput.string.lines.map(&:chomp)
      # noinspection RubyResolve
      expect(output).not_to be_empty

      test_logger.fatal 'Fatal message'
      output = logoutput.string.lines.map(&:chomp)
      # noinspection RubyResolve
      expect(output).not_to be_empty
    end

  end

  context 'with application configuration' do

    it 'should print default application name' do
      test_logger.set_application
      test_logger.info 'Info message'
      output = logoutput.string.lines.map(&:chomp)
      expect(output.size).to eq 1
      expect(output.last).to match /^I, #{timestamp_regex}  INFO -- TestLogger : Info message$/
    end

    it 'should print custom application name' do
      test_logger.set_application 'TestApplication'
      test_logger.info 'Info message'
      output = logoutput.string.lines.map(&:chomp)
      expect(output.size).to eq 1
      expect(output.last).to match /^I, #{timestamp_regex}  INFO -- TestApplication : Info message$/
    end

    it 'should allow to turn of application name' do
      test_logger.set_application 'TestApplication'
      test_logger.info 'Info message'
      output = logoutput.string.lines.map(&:chomp)
      expect(output.size).to eq 1
      expect(output.last).to match /^I, #{timestamp_regex}  INFO -- TestApplication : Info message$/
      # -- revert to default
      test_logger.set_application
      test_logger.info 'Info message'
      output = logoutput.string.lines.map(&:chomp)
      expect(output.size).to eq 2
      expect(output.last).to match /^I, #{timestamp_regex}  INFO -- TestLogger : Info message$/
      # -- turn off
      test_logger.set_application ''
      test_logger.info 'Info message'
      output = logoutput.string.lines.map(&:chomp)
      expect(output.size).to eq 3
      expect(output.last).to match /^I, #{timestamp_regex}  INFO : Info message$/
    end

  end

  context 'with subject configuration' do

    it 'should print no subject by default' do
      test_logger.set_subject
      test_logger.info 'Info message'
      output = logoutput.string.lines.map(&:chomp)
      expect(output.size).to eq 1
      expect(output.last).to match /^I, #{timestamp_regex}  INFO : Info message$/
    end

    it 'should print custom subject name' do
      test_logger.set_subject 'TestSubject'
      test_logger.info 'Info message'
      output = logoutput.string.lines.map(&:chomp)
      expect(output.size).to eq 1
      expect(output.last).to match /^I, #{timestamp_regex}  INFO - TestSubject : Info message$/
    end

    it 'should allow to turn off subject name' do
      test_logger.set_subject 'TestSubject'
      test_logger.info 'Info message'
      output = logoutput.string.lines.map(&:chomp)
      expect(output.size).to eq 1
      expect(output.last).to match /^I, #{timestamp_regex}  INFO - TestSubject : Info message$/
      # -- turn off
      test_logger.set_subject
      test_logger.info 'Info message'
      output = logoutput.string.lines.map(&:chomp)
      expect(output.size).to eq 2
      expect(output.last).to match /^I, #{timestamp_regex}  INFO : Info message$/
    end

  end

end
