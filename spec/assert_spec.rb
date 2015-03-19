# encoding: utf-8
require_relative 'spec_helper'
require 'libis/tools/assert'

describe 'Assert' do

  before :example do
    $DEBUG = true
  end

  after :example do
    $DEBUG = false
  end

  it 'should throw an assert exception when statement is false' do

    message = 'Testing the assert with false.'
    expect {
      assert(false, message)
    }.to raise_error(AssertionFailure, message)

  end

  it 'should only throw an assert in debug mode' do

    $DEBUG = false
    expect {
      assert(false, 'Testing the assert with false.')
    }.to_not raise_error

  end

  it 'should not throw an assert if statement is true' do

    expect {
      assert(true, 'Testing the assert with true.')
    }.to_not raise_error

  end

  it 'should throw an assert on nil' do

    message = 'Testing the assert with nil.'
    expect {
      assert(nil, message)
    }.to raise_error(AssertionFailure, message)
  end

  it 'should check the given block if present' do

    message = 'block test'
    expect {
      assert(message) do
        false
      end
    }.to raise_error(AssertionFailure, message)

    expect {
      assert(message) do
        true
      end
    }.to_not raise_error

  end
end