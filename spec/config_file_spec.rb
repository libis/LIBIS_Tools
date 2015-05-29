# encoding: utf-8
require_relative 'spec_helper'
require 'libis/tools/config_file'

describe ::Libis::Tools::ConfigFile do

  let!(:test_file) { File.join(File.dirname(__FILE__), 'data', 'test_config.yml') }

  let(:hash) {
    {
        a: {x: 0, y: 0, z: 0},
        b: {x: 10, y: -5, z: 2.5},
        c: [
            [
                {a: [{a1: 1, a2: 2}]},
            ]
        ]
    }
  }

  context 'after default initialization' do

    it 'has empty hash' do
      # noinspection RubyResolve
      expect(subject.to_hash).to be_empty
    end

    it 'loads from file' do
      subject << test_file
      expect(subject.to_hash).to eq hash
    end

    it 'loads a hash' do
      subject << hash
      expect(subject.to_hash).to eq hash
    end

    it 'allows to change sub-hash' do
      subject << hash
      # noinspection RubyResolve
      subject.b.v = 1
      hash[:b]['v'] = 1
      expect(subject.to_hash).to eq hash
    end

    it 'allows to change hash in array' do
      subject << hash
      # noinspection RubyResolve
      subject.c[0][0].a[0].v = 1
      hash[:c][0][0][:a][0]['v'] = 1
      expect(subject.to_hash).to eq hash
    end

  end

  context 'initialization with hash' do
    subject { ::Libis::Tools::ConfigFile.new hash }

    it 'has hash' do
      expect(subject.to_hash).to eq hash
    end

  end

  context 'initialization with file' do
    subject { ::Libis::Tools::ConfigFile.new test_file }

    it 'has hash' do
      expect(subject.to_hash).to eq hash
    end

  end

end