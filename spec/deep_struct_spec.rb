# encoding: utf-8
require_relative 'spec_helper'
require 'libis/tools/deep_struct'

describe 'DeepStruct' do

  context 'default contructor' do

    subject(:ds) { Libis::Tools::DeepStruct.new }

    it 'should initialize' do
      is_expected.not_to be_nil
      # noinspection RubyResolve
      expect(ds.to_hash).to be_empty
    end

  end

  context 'contructed with hash' do

    let(:hash) { {a: 1, 'b' => '2', c: 3.0} }
    subject(:ds) { Libis::Tools::DeepStruct.new(hash)}

    it 'has Hash values initialized' do
      expect(ds[:a]).to eq 1
      expect(ds[:b]).to eq '2'
      expect(ds[:c]).to eq 3.0
      expect(ds.to_hash).to eq hash
    end

    it 'allows access through methods' do
      expect(ds.a).to eq 1
      expect(ds.b).to eq '2'
      expect(ds.c).to eq 3.0

      ds.a = 5
      expect(ds.a).to be 5
      expect(ds[:a]).to be 5
      expect(ds['a']).to be 5
    end

    it 'allows access through key strings' do
      expect(ds['a']).to eq 1
      expect(ds['b']).to eq '2'
      expect(ds['c']).to eq 3.0

      ds['a'] = 5
      expect(ds.a).to be 5
      expect(ds[:a]).to be 5
      expect(ds['a']).to be 5
    end

    it 'allows access through key symbols' do
      expect(ds[:a]).to eq 1
      expect(ds[:b]).to eq '2'
      expect(ds[:c]).to eq 3.0

      ds[:a] = 5
      expect(ds.a).to be 5
      expect(ds[:a]).to be 5
      expect(ds['a']).to be 5
    end

  end

  context 'initialized with non-hash' do

    subject(:ds) { Libis::Tools::DeepStruct.new 'abc' }

    it 'stores value in hash with :default key' do
      expect(ds[:default]).to eq 'abc'
    end

  end

  context 'initialized with nil value' do

    subject(:ds) { Libis::Tools::DeepStruct.new nil }

    it 'has no data' do
      # noinspection RubyResolve
      expect(ds.to_hash).to be_empty
    end

  end

  context 'initialized with recursive hash' do

    let(:recursive_hash) { {
        a: {x: 0, y: 0, z: 0},
        b: {x: 10, y: -5, z: 2.5},
        c: [
            [
                {a: [ {a1: 1, a2: 2}] },
            ]
        ]
    } }

    subject(:ds) { Libis::Tools::DeepStruct.new(recursive_hash) }

    it 'stores recursive Hashes as DeepStructs' do
      expect(ds[:a]).to be_a Libis::Tools::DeepStruct
      expect(ds.b).to be_a Libis::Tools::DeepStruct
    end

    it 'recurses over arrays' do
      expect(ds.c[0][0]).to be_a Libis::Tools::DeepStruct
      expect(ds.c.first.first.a.first.a1).to eq 1
      expect(ds.c.first.first.a.first.a2).to eq 2
    end

    it 'can reproduce original hash' do
      expect(ds.to_hash).to eq recursive_hash
      expect(ds.b.to_hash).to eq recursive_hash[:b]
    end

    it 'clears data and methods' do
      expect(ds).to respond_to 'a'
      expect(ds).to respond_to 'b'
      expect(ds).to respond_to 'c'
      expect(ds).to respond_to 'a='
      expect(ds).to respond_to 'b='
      expect(ds).to respond_to 'c='

      ds.clear!
      expect(ds.a).to be_nil
      expect(ds.b).to be_nil
      expect(ds.c).to be_nil
      expect(ds).not_to respond_to 'a'
      expect(ds).not_to respond_to 'b'
      expect(ds).not_to respond_to 'c'
      expect(ds).not_to respond_to 'a='
      expect(ds).not_to respond_to 'b='
      expect(ds).not_to respond_to 'c='
    end

  end
end