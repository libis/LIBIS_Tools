# coding: utf-8

### require 'tools/string'

require 'LIBIS/tools/format/type_database'

require_relative 'repository'

module LIBIS
  module Tools
    module Conveter

      class Base

        protected

        attr_accessor :options, :flags

        public

        def initialize( source = nil, options = {}, flags = {} )
          @options ||= {}
          @options.merge! options if options
          @flags ||= {}
          @flags.merge! flags if flags
          init(source.to_s) if source
        end

        def convert(target, format = nil)
          do_convert(target, format)
        end

        def init(_)
          raise RuntimeError, 'Method #init should be implemented in converter'
        end

        def do_convert(_, _)
          raise RuntimeError, 'Method #do_convert should be implemented in converter'
        end

        def Base.inherited( klass )

          Repository.register klass

          class << self
            def input_types
              []
            end

            def output_types
              []
            end

            def conversions
              input_types.inject({}) do |input_type, hash|
                hash[input_type] = output_types
                hash
              end
            end

            def input_type?(type_id)
              input_types.include? type_id
            end

            def output_type?(type_id)
              output_types.include? type_id
            end

            def input_mimetype?(mimetype)
              type_id = TypeDatabase.instance.mime2type mimetype
              input_type? type_id
            end

            def output_mimetype?(mimetype)
              type_id = TypeDatabase.instance.mime2type mimetype
              output_type? type_id
            end

            def conversion?(input_type, output_type)
              conversions[input_type] and conversions[input_type].any? { |t| t == output_type }
            end

            def output_for(input_type)
              conversions[input_type]
            end

            def extension?(extension)
              TypeDatabase.ext2type extension
            end

          end


        end


      end

    end
  end
end
