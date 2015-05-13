# encoding: utf-8
require_relative 'spec_helper'
require 'libis/tools/deep_struct'

describe 'DeepStruct' do

  hash = {a: 1, 'b' => '2', c: 3.0}
  recursive_hash = {
      a: {x: 0, y: 0, z: 0},
      b: {x: 10, y: -5, z: 2.5},
      c: [
          [
              {a: 1},
              {a: 2}
          ]
      ]
  }

  it 'should initialize' do
    ds = Libis::Tools::DeepStruct.new
    expect(ds).not_to eq nil
  end

  # noinspection RubyResolve
  it 'should store Hash values' do
    ds = Libis::Tools::DeepStruct.new hash
    expect(ds[:a]).to eq 1
    expect(ds[:b]).to eq '2'
    expect(ds[:c]).to eq 3.0
  end

  it 'should allow access through methods' do
    ds = Libis::Tools::DeepStruct.new hash
    expect(ds.a).to eq 1
    expect(ds.b).to eq '2'
    expect(ds.c).to eq 3.0
  end

  it 'should allow access through methods, key strings and key symbols' do
    ds = Libis::Tools::DeepStruct.new hash
    expect(ds.a).to eq 1
    expect(ds.b).to eq '2'
    expect(ds.c).to eq 3.0

    expect(ds['a']).to eq 1
    expect(ds['b']).to eq '2'
    expect(ds['c']).to eq 3.0

    expect(ds[:a]).to eq 1
    expect(ds[:b]).to eq '2'
    expect(ds[:c]).to eq 3.0

    expect(ds.b).to be ds[:b]
    expect(ds.b).to be ds['b']

  end

  it 'should store non-hashes with :default key' do
    ds = Libis::Tools::DeepStruct.new 'abc'
    expect(ds[:default]).to eq 'abc'
  end

  it 'should store recursive Hashes as DeepStructs' do
    ds = Libis::Tools::DeepStruct.new(recursive_hash)
    expect(ds[:a]).to be_a Libis::Tools::DeepStruct
    expect(ds.b).to be_a Libis::Tools::DeepStruct
  end

  it 'should recurse over arrays by default' do
    ds = Libis::Tools::DeepStruct.new(recursive_hash)
    expect(ds.c[0][0]).to be_a Libis::Tools::DeepStruct
    expect(ds.c.first.first.a).to eq 1
    expect(ds.c.first[1].a).to eq 2
  end

  it 'should deliver hashes if asked' do
    ds = Libis::Tools::DeepStruct.new(recursive_hash)
    expect(ds.to_h).to eq recursive_hash
    expect(ds.b.to_h).to eq recursive_hash[:b]
  end

end