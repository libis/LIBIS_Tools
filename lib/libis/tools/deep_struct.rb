require 'libis/tools/extend/ostruct'
require 'recursive-open-struct'

module Libis
  module Tools
    class DeepStruct < RecursiveOpenStruct

      def initialize(hash = {}, opts = {})
        hash = {default: hash} unless hash.is_a? Hash
        super(hash, {recurse_over_arrays: true}.merge(opts))
      end

    end
  end
end
