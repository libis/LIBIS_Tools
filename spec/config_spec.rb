# encoding: utf-8
require_relative 'spec_helper'
require 'libis/tools/config'

describe 'Config' do

  config = ::Libis::Tools::Config
  config << { appname: 'LIBIS Default' }

  it 'should initialize' do
    expect(config.appname).to eq 'LIBIS Default'
    expect(config.logger).to be_a ::Logger
  end

  # noinspection RubyResolve
  it 'should define setters' do
    config[:test_value] = 5
    expect(config.test_value).to eq 5
  end

  it 'should load from file' do
    config << 'data/test.yml'
    expect(config.process).to eq 'Test Configuration'
  end

  # noinspection RubyResolve
  it 'should allow to set and get in different ways' do
    config.test_value = 10
    expect(config.test_value).to be 10
    expect(config['test_value']).to be 10
    expect(config[:test_value]).to be 10
    expect(config.instance.test_value).to be 10
    expect(config.instance['test_value']).to be 10
    expect(config.instance[:test_value]).to be 10

    config[:test_value] = 11
    expect(config.test_value).to be 11
    expect(config['test_value']).to be 11
    expect(config[:test_value]).to be 11
    expect(config.instance.test_value).to be 11
    expect(config.instance['test_value']).to be 11
    expect(config.instance[:test_value]).to be 11

    config['test_value'] = 12
    expect(config.test_value).to be 12
    expect(config['test_value']).to be 12
    expect(config[:test_value]).to be 12
    expect(config.instance.test_value).to be 12
    expect(config.instance['test_value']).to be 12
    expect(config.instance[:test_value]).to be 12
  end

  it 'should allow to set and get on class and instance' do
    expect(config.appname).to be config.instance.appname
    expect(config['appname']).to be config.instance.appname
    expect(config[:appname]).to be config.instance.appname
    expect(config.instance['appname']).to be config.instance.appname
    expect(config.instance[:appname]).to be config.instance.appname

    config.instance[:appname] = 'Test App'
    expect(config.appname).to be == 'Test App'
  end

  # noinspection RubyResolve
  it 'should reset only values loaded from file' do
    config[:appname] = 'foo'
    config[:process] = 'bar'
    config[:baz] = 'qux'

    expect(config.appname).to eq 'foo'
    expect(config.process).to eq 'bar'
    expect(config.baz).to eq 'qux'

    config.reload
    expect(config.appname).to eq 'LIBIS Default'
    expect(config.process).to eq 'Test Configuration'
    expect(config.baz).to eq 'qux'

    config.reload!
    expect(config.appname).to eq 'LIBIS Default'
    expect(config.process).to eq 'Test Configuration'
    expect(config.baz).to be_nil
  end

end