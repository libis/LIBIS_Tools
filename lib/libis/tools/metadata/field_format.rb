# coding: utf-8

module Libis
  module Tools
    module Metadata

      # Helper class for formatting field data.
      #
      # The FieldFormat class can omit prefix and or postfix if no data is present and omits the join string if only
      # one data element is present.
      class FieldFormat

        # [Array] the list that makes up the data
        attr_accessor :parts

        # [String] the text that will be placed in front of the generated text
        attr_accessor :prefix

        # [String] the text that will be placed at the end of the generated text
        attr_accessor :postfix

        # [String] the text used between the parts of the data
        attr_accessor :join

        # Create new formatter
        #
        # The method takes any number of arguments and processes them as data parts. If the last one is a Hash, it is
        # interpreted as options hash. The data parts can either be given as an Array or set of arguments or within the
        # options hash with key +:parts+.
        #
        # On each element in the data set the formatter will call the #to_s method to
        # give each data object the opportunity to process it's data.
        #
        # @param [Array, Hash] parts whatever makes up the data to be formatted.
        def initialize(*parts)
          @parts = []
          self[*parts]
        end

        # Parses the arguments, stripping of an optional last Hash as options.
        # @param (see #initialize)
        def [](*parts)
          options = parts.last.is_a?(Hash) ? parts.pop : {}
          add parts
          x = options.delete(:parts)
          add x if x
          add_options options
        end

        # Set options.
        #
        # Besides the tree options +:prefix+, +:postfix+ and +:join+ it also accepts the option +:fix+. This combines
        # both +:prefix+ and +:postfix+ options by specifying "<prefix>|<postfix>". If both prefix and postfix are only
        # 1 character wide the format "<prefix><postfix>" is also allowed.
        #
        # @param [Hash] options the options list
        def add_options(options = {})
          if options[:fix]
            if options[:fix].size == 2
              @prefix, @postfix = options[:fix].split('')
            else
              @prefix, @postfix = options[:fix].split('|')
            end
          end
          @join = options[:join] if options[:join]
          @prefix = FieldFormat::from(options[:prefix]) if options[:prefix]
          @postfix = FieldFormat::from(options[:postfix]) if options[:postfix]
          self
        end

        # Add default options.
        # (see #add_options)
        # None of these options will be set if they are already set. If you need to overwrite them, use {#add_options}.
        # @param (see #add_options)
        def add_default_options(options = {})
          options.delete(:prefix) if @prefix
          options.delete(:postfix) if @postfix
          options.delete(:fix) if @prefix or @postfix
          options.delete(:join) if @join
          add_options options
        end

        # Shortcut class method for initializer
        def self.from(*h)
          self.new(*h)
        end

        # The real formatter method.
        # This method parses the data and applies the options to generate the formatted string.
        # @return [String] the formatter string
        def to_s
          @parts.delete_if { |x|
            x.nil? or
                (x.is_a? String and x.empty?) or
                (x.is_a? Libis::Tools::Metadata::FieldFormat and x.to_s.empty?)
          }
          result = @parts.join(@join)
          unless result.empty?
            result = (@prefix || '').to_s + result + (@postfix || '').to_s
          end
          result
        end

        protected

        def add(part)
          case part
            when Hash
              @parts << Libis::Tools::Metadata::FieldFormat::from(part)
            when Array
              part.each { |x| add x }
            else
              @parts << part
          end
        end

      end

    end
  end
end
