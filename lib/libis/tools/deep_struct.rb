require 'libis/tools/extend/ostruct'
require 'recursive-open-struct'

module Libis
  module Tools

    # A class that derives from OpenStruct through the RecursiveOpenStruct. A RecursiveOpenStruct is derived from
    # stdlib's OpenStruct, but can be made recursive. DeepStruct enforces this behaviour and adds a clear! method.
    class DeepStruct < RecursiveOpenStruct

      def initialize(hash = {}, opts = {})
        hash = {} unless hash
        opts = {} unless opts
        hash = {default: hash} unless hash.is_a? Hash
        super(hash, {recurse_over_arrays: true, preserve_original_keys: true}.merge(opts))
      end

      # Delete all data fields
      def clear!
        @table.keys.each { |key| delete_field(key) }
        @sub_elements = {}
      end

    end
  end
end
