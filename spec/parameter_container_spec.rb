# encoding: utf-8
require_relative 'spec_helper'
require 'libis/tools/parameter'

describe 'ParameterContainer' do

  class TestContainer
    include ::Libis::Tools::ParameterContainer

    parameter check: true, description: 'check parameter'
    parameter count: 0, description: 'count parameter'
    parameter price: 1.0, description: 'price parameter'
    parameter name: 'nobody', description: 'name parameter'
    parameter calendar: Date.new(2014, 01, 01)
    parameter clock: Time.parse('10:10')
    parameter timestamp: DateTime.new(2014, 01, 01, 10, 10)
    parameter with_options: true, options: {a: 1, b: 2}, c: 3

  end

  class DerivedContainer < TestContainer
    parameter name: 'somebody', description: 'derived name parameter', frozen: true
    parameter check: 'no'
    parameter new_derived_param: false
  end

  class DerivedDerivedContainer < DerivedContainer
    parameter price: 2.0, description: 'derived derived price parameter'
  end

  class DerivedDerivedDerivedContainer < DerivedDerivedContainer
    parameter price: 3.0, description: 'derived derived derived price parameter'
  end

  let(:test_container) { TestContainer.new }
  let(:derived_container) { DerivedContainer.new }
  let(:derived_derived_container) { DerivedDerivedContainer.new }
  let(:derived_derived_derived_container) { DerivedDerivedDerivedContainer.new }

  it 'class should return parameter if only name is given' do
    [:check, :count, :price, :name, :calendar, :clock, :timestamp].each do |v|
      expect(TestContainer.parameter(v)).to be_a ::Libis::Tools::Parameter
    end
  end

  it 'should have default parameters' do
    expect(test_container.parameter(:check)).to be_truthy
    expect(test_container.parameter(:count)).to eq 0
    expect(test_container.parameter(:price)).to eq 1.0
    expect(test_container.parameter(:name)).to eq 'nobody'
    expect(test_container.parameter(:calendar).year).to eq 2014
    expect(test_container.parameter(:calendar).month).to eq 1
    expect(test_container.parameter(:calendar).day).to eq 1
    expect(test_container.parameter(:clock).hour).to eq 10
    expect(test_container.parameter(:clock).min).to eq 10
    expect(test_container.parameter(:clock).sec).to eq 0
    expect(test_container.parameter(:timestamp).year).to eq 2014
    expect(test_container.parameter(:timestamp).month).to eq 1
    expect(test_container.parameter(:timestamp).day).to eq 1
    expect(test_container.parameter(:timestamp).hour).to eq 10
    expect(test_container.parameter(:timestamp).min).to eq 10
    expect(test_container.parameter(:timestamp).sec).to eq 0
  end

  it 'should allow to set values' do
    test_container.parameter(:check, false)
    expect(test_container.parameter(:check)).to be_falsey

    test_container.parameter(:count, 99)
    expect(test_container.parameter(:count)).to eq 99

    test_container.parameter(:price, 99.99)
    expect(test_container.parameter(:price)).to eq 99.99

    test_container.parameter(:name, 'everybody')
    expect(test_container.parameter(:name)).to eq 'everybody'

    test_container.parameter(:calendar, Date.new(2015, 02, 03))
    expect(test_container.parameter(:calendar).year).to eq 2015
    expect(test_container.parameter(:calendar).month).to eq 2
    expect(test_container.parameter(:calendar).day).to eq 3

    test_container.parameter(:clock, Time.parse('14:40:23'))
    expect(test_container.parameter(:clock).hour).to eq 14
    expect(test_container.parameter(:clock).min).to eq 40
    expect(test_container.parameter(:clock).sec).to eq 23

    test_container.parameter(:timestamp, DateTime.new(2015, 02, 03, 14, 40, 23))
    expect(test_container.parameter(:timestamp).year).to eq 2015
    expect(test_container.parameter(:timestamp).month).to eq 2
    expect(test_container.parameter(:timestamp).day).to eq 3
    expect(test_container.parameter(:timestamp).hour).to eq 14
    expect(test_container.parameter(:timestamp).min).to eq 40
    expect(test_container.parameter(:timestamp).sec).to eq 23
  end

  it 'should be able to define parameter with options' do
    expect(test_container.class.parameter(:with_options)[:options]).to eq a: 1, b: 2, c: 3
    expect(test_container.class.parameter(:with_options)[:options][:a]).to be 1
    expect(test_container.class.parameter(:with_options)[:a]).to be 1
    expect(test_container.class.parameter(:with_options)[:options][:c]).to be 3
    expect(test_container.class.parameter(:with_options)[:c]).to be 3
  end

  it 'derived class should inherit parameters of the parent class' do
    expect(derived_container.parameter(:price)).to eq 1.0
    expect(derived_container.class.parameter(:price)[:description]).to eq 'price parameter'
  end

  it 'derived class should override parameter values and propertiesfrom parent class' do
    expect(derived_container.parameter(:name)).to eq 'somebody'
    expect(derived_container.parameter(:check)).to eq 'no'
  end

  it 'overrides in the derived classes should not change values in the parent classes' do
    expect(test_container.parameter(:check)).to eq true
    expect(test_container.parameter(:price)).to eq 1.0
    expect(test_container.class.parameter(:price)[:description]).to eq 'price parameter'
  end

  it 'derivation should be supported over multiple levels' do
    expect(derived_container.parameter(:price)).to eq 1.0
    expect(derived_derived_container.parameter(:price)).to eq 2.0
    expect(derived_derived_derived_container.parameter(:price)).to eq 3.0
    expect(derived_container.class.parameter(:price)[:description]).to eq 'price parameter'
    expect(derived_derived_container.class.parameter(:price)[:description]).to eq 'derived derived price parameter'
    expect(derived_derived_derived_container.class.parameter(:price)[:description]).to eq 'derived derived derived price parameter'
  end

  it 'frozen parameters should be read-only' do
    expect {
      derived_container.parameter(:name, 'anybody')
    }.to raise_error(::Libis::Tools::ParameterFrozenError)
    expect(derived_container.parameter(:name)).to eq 'somebody'
    expect {
      derived_container[:name] = 'anybody'
    }.not_to raise_error
    expect(derived_container[:name]).to eq 'somebody'
  end

  it 'frozen state should not affect parameter in parent class' do
    expect {
      test_container.parameter(:name, 'anybody')
    }.not_to raise_error
    expect(test_container.parameter(:name)).to eq 'anybody'
    expect {
      test_container[:name] = 'everybody'
    }.not_to raise_error
    expect(test_container[:name]).to eq 'everybody'
  end

end