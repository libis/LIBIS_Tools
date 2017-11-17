require_relative 'spec_helper'
require 'awesome_print'
require 'libis/tools/thread_safe'

describe 'ThreadSafe' do

  class Foo
    include Libis::Tools::ThreadSafe

    def self.bar
      self.class_mutex.synchronize {
        @bar ||= get_number
      }
    end

    def self.get_number
      nr = rand(1000000)
      sleep 1
      nr
    end
  end

  it 'protects class variable' do
    mutex = Monitor.new
    result = []
    1000.times.map do
      Thread.new do
        a = Foo.bar
        mutex.synchronize {result << a}
      end
    end.each(&:join)
    result.uniq!
    # ap result
    expect(result.size).to be 1
  end

  class Bar

    def self.bar
      @bar ||= get_number
    end

    def self.get_number
      nr = rand(1000000)
      sleep 1
      nr
    end
  end

  it 'without not thread safe' do
    mutex = Monitor.new
    result = []
    1000.times.map do
      Thread.new do
        a = Bar.bar
        mutex.synchronize {result << a}
      end
    end.each(&:join)
    result.uniq!
    # ap result
    expect(result.size).not_to be 1
  end

end
