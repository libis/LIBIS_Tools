# encoding: utf-8
require_relative 'spec_helper'
require 'libis/tools/config'
require 'libis/tools/logger'

describe 'Logger' do

  class TestLogger
    include ::Libis::Tools::Logger
  end

  before(:context) do
  end

  before(:example) do
    appender = ::Logging::Appenders.string_io('StringIO', layout: ::Libis::Tools::Config.get_log_formatter)
    ::Libis::Tools::Config.logger.add_appenders(appender)
    @logoutput = appender.sio
    ::Libis::Tools::Config.logger.level = :all
    @test_logger = TestLogger.new
  end
  
  let(:timestamp_regex) { '\[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3} #\d+\.\d+\]'}

  it 'should log debug output' do
    @test_logger.debug 'Debug message'
    puts "LOG OUTPUT: #{@logoutput.string}"
    output = @logoutput.string.lines.map(&:chomp)
    expect(output.size).to eq 1
    expect(output.first).to match /^D, #{timestamp_regex} DEBUG : Debug message$/
  end

  it 'should log info output' do
    @test_logger.info 'Info message'
    output = @logoutput.string.lines.map(&:chomp)
    expect(output.size).to eq 1
    expect(output.first).to match /^I, #{timestamp_regex}  INFO : Info message$/
  end

  it 'should log warning output' do
    @test_logger.warn 'Warning message'
    output = @logoutput.string.lines.map(&:chomp)
    expect(output.size).to eq 1
    expect(output.first).to match /^W, #{timestamp_regex}  WARN : Warning message$/
  end

  it 'should log error output' do
    @test_logger.error 'Error message'
    output = @logoutput.string.lines.map(&:chomp)
    expect(output.size).to eq 1
    expect(output.first).to match /^E, #{timestamp_regex} ERROR : Error message$/
  end

  it 'should log fatal output' do
    @test_logger.fatal 'Fatal message'
    output = @logoutput.string.lines.map(&:chomp)
    expect(output.size).to eq 1
    expect(output.first).to match /^F, #{timestamp_regex} FATAL : Fatal message$/
  end

  it 'should be quiet when asked to' do
    ::Libis::Tools::Config.logger.level = :error

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

end