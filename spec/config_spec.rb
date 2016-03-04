# encoding: utf-8
require_relative 'spec_helper'
require 'libis/tools/config'

describe 'Config' do

  before(:all) do
    ::Libis::Tools::Config << {appname: 'LIBIS Default'}
  end

  subject(:config) { ::Libis::Tools::Config.clear! }

  it 'has defaults set' do
    expect(config.logger).to be_a ::Logging::Logger
  end

  it 'clears all values' do
    # noinspection RubyResolve
    config.test_value = 5
    config.logger.level = :FATAL
    # noinspection RubyResolve
    expect(config.test_value).to be 5
    expect(config.logger.level).to be ::Logging::level_num(:FATAL)

    config.clear!
    # noinspection RubyResolve
    expect(config.test_value).to be_nil
  end

  context 'adding values with setters' do

    it 'by symbol' do
      config[:test_value] = 5
      expect(config['test_value']).to be 5
    end

    it 'by name' do
      config['test_value'] = 6
      # noinspection RubyResolve
      expect(config.test_value).to be 6
    end

    it 'by method' do
      # noinspection RubyResolve
      config.test_value = 7
      expect(config[:test_value]).to be 7
    end

    it 'allows to set on instance' do
      config.instance[:test_value] = :abc
      # noinspection RubyResolve
      expect(config.test_value).to be :abc
    end

    it 'allows to set on class' do
      # noinspection RubyResolve
      config.test_value = :def
      expect(config.instance[:test_value]).to be :def
    end

  end

  context 'loading from file' do

    let(:test_file) { File.join(File.dirname(__FILE__), 'data', 'test.yml') }
    subject(:config) {
      Libis::Tools::Config.clear! << test_file
    }

    it 'has configuration parameters set' do
      expect(config.process).to eq 'Test Configuration'
    end

    it 'resets only values loaded from file' do
      config[:process] = 'foo'
      config[:bar] = 'qux'

      expect(config.process).to eq 'foo'
      expect(config.bar).to eq 'qux'

      config.reload
      expect(config.process).to eq 'Test Configuration'
      expect(config.bar).to eq 'qux'
    end

    it 'resets all values' do
      config[:process] = 'foo'
      config[:bar] = 'qux'

      expect(config.process).to eq 'foo'
      expect(config.bar).to eq 'qux'

      config.reload!
      expect(config.process).to eq 'Test Configuration'
      expect(config.bar).to be_nil
    end

    it 'clears all values' do
      config[:process] = 'foo'
      config[:bar] = 'qux'

      expect(config.process).to eq 'foo'
      expect(config.bar).to eq 'qux'

      config.clear!
      expect(config.process).to be_nil
      expect(config.bar).to be_nil
      # noinspection RubyResolve
      expect(config.to_h).to be_empty
    end

  end
end