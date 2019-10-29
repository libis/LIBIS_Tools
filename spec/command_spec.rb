# encoding: utf-8
require_relative 'spec_helper'
require 'libis/tools/command'

describe 'Command' do

  let!(:dir) { Dir.pwd }
  let(:entries) {
    Dir.entries('.').inject([]) do |array, value|
      array << value unless File.directory?(value)
      array
    end.sort
  }

  before(:each) { Dir.chdir(File.join(File.dirname(__FILE__),'data')) }
  after(:each) { Dir.chdir(dir) }

  it 'should run ls command' do

    result = Libis::Tools::Command.run('ls')

    expect(result[:out].sort).to match entries
    expect(result[:err]).to eq []
    expect(result[:status]).to eq 0

  end

  it 'should run ls command with an option' do

    result = Libis::Tools::Command.run('ls', '-1')

    output = result[:out]
    expect(output.size).to eq entries.size
    expect(output.sort).to match entries
    expect(result[:err]).to eq []
    expect(result[:status]).to eq 0

  end

  it 'should run ls command with multiple options' do

    result = Libis::Tools::Command.run('ls', '-1', '-a', '-p')

    output = result[:out]
    expect(output.size).to eq entries.size + 2
    expect(output[0]).to eq './'
    expect(output[1]).to eq '../'
    expect(output[2..-1].sort).to match entries
    expect(result[:err]).to eq []
    expect(result[:status]).to eq 0

  end

  it 'should capture error output and status' do

    result = Libis::Tools::Command.run('ls', 'abc')
    expect(result[:out]).to eq []
    expect(result[:err].size).to eq 1
    expect(result[:err][0]).to match /ls: cannot access '?abc'?: No such file or directory/
    expect(result[:status]).to eq 2

  end

  it 'should allow to supply input data' do

    result = Libis::Tools::Command.run('cat', stdin_data: "FooBar", timeout: 1)
    expect(result[:out]).to eq ['FooBar']
    expect(result[:err].size).to eq 0
    expect(result[:status]).to eq 0

  end

  it 'should not timeout if command finishes' do

    result = Libis::Tools::Command.run('cat', stdin_data: "FooBar", timeout: 1)
    expect(result[:timeout]).to be_falsey

  end

  it 'should timeout if command hangs' do

    result = Libis::Tools::Command.run('ls', '-aRlp', '/', timeout: 1)
    expect(result[:timeout]).to be_truthy

  end

end