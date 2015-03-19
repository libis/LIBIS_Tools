# encoding: utf-8
require_relative 'spec_helper'
require 'libis/tools/config'
require 'libis/tools/logger'

describe 'Logger' do

  class TestLogger
    include ::Libis::Tools::Logger
    attr_accessor :options
    def initialize
      @options = {}
    end
  end

  before(:context) do
  end

  before(:example) do
    ::Libis::Tools::Config[:appname] = ''
    @logoutput = StringIO.new
    ::Libis::Tools::Config.logger = ::Logger.new @logoutput
    ::Libis::Tools::Config.logger.level = ::Logger::DEBUG
    @test_logger = TestLogger.new
  end

  it 'should log debug output' do
    @test_logger.debug 'Debug message'
    output = @logoutput.string.lines.map(&:chomp)
    expect(output.size).to be 1
    expect(output.first).to match /^D, \[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{6} #\d+\] DEBUG -- TestLogger: Debug message$/
  end

  it 'should log info output' do
    @test_logger.info 'Info message'
    output = @logoutput.string.lines.map(&:chomp)
    expect(output.size).to be 1
    expect(output.first).to match /^I, \[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{6} #\d+\]  INFO -- TestLogger: Info message$/
  end

  it 'should log warning output' do
    @test_logger.warn 'Warning message'
    output = @logoutput.string.lines.map(&:chomp)
    expect(output.size).to be 1
    expect(output.first).to match /^W, \[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{6} #\d+\]  WARN -- TestLogger: Warning message$/
  end

  it 'should log error output' do
    @test_logger.error 'Error message'
    output = @logoutput.string.lines.map(&:chomp)
    expect(output.size).to be 1
    expect(output.first).to match /^E, \[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{6} #\d+\] ERROR -- TestLogger: Error message$/
  end

  it 'should log fatal output' do
    @test_logger.fatal 'Fatal message'
    output = @logoutput.string.lines.map(&:chomp)
    expect(output.size).to be 1
    expect(output.first).to match /^F, \[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{6} #\d+\] FATAL -- TestLogger: Fatal message$/
  end

  it 'should be quiet when asked to' do
    @test_logger.options[:quiet] = true

    @test_logger.debug 'Debug message'
    output = @logoutput.string.lines.map(&:chomp)
    # noinspection RubyResolve
    expect(output).to be_empty

    @test_logger.info 'Info message'
    output = @logoutput.string.lines.map(&:chomp)
    # noinspection RubyResolve
    expect(output).to be_empty

    @test_logger.warn 'Warn message'
    output = @logoutput.string.lines.map(&:chomp)
    # noinspection RubyResolve
    expect(output).to be_empty

    @test_logger.error 'Error message'
    output = @logoutput.string.lines.map(&:chomp)
    # noinspection RubyResolve
    expect(output).not_to be_empty

    @test_logger.fatal 'Fatal message'
    output = @logoutput.string.lines.map(&:chomp)
    # noinspection RubyResolve
    expect(output).not_to be_empty
  end

  it 'should display application name in log' do
    ::Libis::Tools::Config[:appname] = 'Test Application'
    @test_logger.info 'Info message'
    output = @logoutput.string.lines.map(&:chomp)
    expect(output.size).to be 1
    expect(output.first).to match /^I, \[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{6} #\d+\]  INFO -- Test Application: Info message$/
  end

  it 'should display name value in log' do
    @test_logger.define_singleton_method(:name) { 'Logger for testing' }
    @test_logger.info 'Info message'
    output = @logoutput.string.lines.map(&:chomp)
    expect(output.size).to be 1
    expect(output.first).to match /^I, \[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{6} #\d+\]  INFO -- Logger for testing: Info message$/
  end

end