# coding: utf-8

module Libis
  module Tools
    module Metadata

      class FixField

        attr_reader :tag
        attr_reader :datas

        def initialize(tag, datas)
          @tag = tag
          @datas = datas || ''
        end

        def dump
          "#{@tag}:'#{@datas}'\n"
        end

      end

    end
  end
end