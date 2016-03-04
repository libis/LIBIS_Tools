# coding: utf-8

module Libis
  module Tools
    module Metadata

      # Helper class for implementing a fixed field for MARC
      class FixField

        attr_reader :tag
        attr_accessor :datas

        # Create new fixed field
        # @param [String] tag tag
        # @param [String] datas field data
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