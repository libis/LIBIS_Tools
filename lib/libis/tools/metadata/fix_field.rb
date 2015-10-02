# coding: utf-8

module Libis
  module Tools
    module Metadata

      class FixField

        attr_reader :tag
        attr_accessor :datas

        def initialize(tag, datas)
          @tag = tag
          @datas = datas || ''
        end

        def [](from = nil, to = nil)
          return @datas unless from
          to ? @datas[from..to] : @datas[from]
        end

        def dump
          "#{@tag}:'#{@datas}'\n"
        end

      end

    end
  end
end