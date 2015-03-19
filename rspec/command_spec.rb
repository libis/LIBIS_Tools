# encoding: utf-8
require_relative 'spec_helper'
require 'libis/tools/command'

describe 'Command' do

  around(:example) do |test|
    Dir.chdir('data')
    test.run
    Dir.chdir('..')
  end

  it 'should run ls command' do

    result = LIBIS::Tools::Command.run('ls')

    expect(result[:out]).to eq %w'test.data test.xml test.yml'
    expect(result[:err]).to eq []
    expect(result[:status]).to be 0

  end

  it 'should run ls command with an option' do

    result = LIBIS::Tools::Command.run('ls', '-l')

    output = result[:out]
    expect(output.size).to be 4
    expect(output.first).to match /^total \d+$/
    expect(output[1]).to match /^-[rwx-]{9}.+test.data$/
    expect(output[2]).to match /^-[rwx-]{9}.+test.xml$/
    expect(output[3]).to match /^-[rwx-]{9}.+test.yml$/

    expect(result[:err]).to eq []
    expect(result[:status]).to be 0

  end

  it 'should run ls command with multiple options' do

    result = LIBIS::Tools::Command.run('ls', '-l', '-a', '-p')

    output = result[:out]
    expect(output.size).to be 6
    expect(output.first).to match /^total \d+$/
    expect(output[1]).to match /^d[rwx-]{9}.+\d+.+\.\/$/
    expect(output[2]).to match /^d[rwx-]{9}.+\d+.+\.\.\/$/
    expect(output[3]).to match /^-[rwx-]{9}.+test.data$/
    expect(output[4]).to match /^-[rwx-]{9}.+test.xml$/
    expect(output[5]).to match /^-[rwx-]{9}.+test.yml$/

    expect(result[:err]).to eq []
    expect(result[:status]).to be 0

  end

  it 'should capture error output and status' do

    result = LIBIS::Tools::Command.run('ls', 'abc')
    expect(result[:out]).to eq []
    expect(result[:err].size).to be 1
    expect(result[:err][0]).to match /ls: cannot access abc: No such file or directory/
    expect(result[:status]).to be 2

  end

end