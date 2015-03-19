# encoding: utf-8
require 'date'
require 'libis/tools/extend/struct'

module Libis
  module Tools

    # noinspection RubyConstantNamingConvention
    Parameter = ::Struct.new(:name, :default, :datatype, :description, :constraint, :options) do

      VALID_PARAMETER_KEYS = [:name, :default, :datatype, :description, :constraint, :options]

      def initialize(*args)
        # noinspection RubySuperCallWithoutSuperclassInspection
        super(*args)
        self.options = {} unless self.options
      end

      TRUE_BOOL = %w'true yes t y 1'
      FALSE_BOOL = %w'false no f n 0'

      def parse(value = nil)
        result = if value.nil?
                   send(:default)
                 else
                     dtype = guess_datatype.to_s.downcase
                     convert(dtype, value)
                 end
        check_constraint(result)
        result
      end

      def valid_value?(value)
        begin
          parse(value)
        rescue
          return false
        end
        true
      end

      def guess_datatype
        return send(:datatype) if send(:datatype)
        case send(:default)
          when TrueClass, FalseClass
            'bool'
          when NilClass
            'string'
          when Integer
            'int'
          when Float
            'float'
          when DateTime, Date, Time
            'datetime'
          else
            send(:default).class.name.downcase
        end
      end

      private

      def convert(dtype, v)
        case dtype.to_s.downcase
          when 'boolean', 'bool'
            return true if TRUE_BOOL.include?(v.to_s.downcase)
            return false if FALSE_BOOL.include?(v.to_s.downcase)
            raise ArgumentError, "No boolean information in '#{v.to_s}'. Valid values are: '#{TRUE_BOOL.join('\', \'')}' and '#{FALSE_BOOL.join('\', \'')}'."
          when 'string'
            return v.to_s.gsub('%s', Time.now.strftime('%Y%m%d%H%M%S'))
          when 'int'
            return Integer(v)
          when 'float'
            return Float(v)
          when 'datetime'
            return v.to_datetime if v.respond_to? :to_datetime
            return DateTime.parse(v)
          else
            raise RuntimeError, "Datatype not supported: '#{dtype}'"
        end
      end

      def check_constraint(v, constraint = nil)
        constraint ||= send(:constraint)
        return if constraint.nil?
        raise ArgumentError, "Value '#{v}' is not allowed (constraint: #{constraint})." unless constraint_checker(v, constraint)
      end

      def constraint_checker(v, constraint)

        case constraint
          when Array
            constraint.each do |c|
              return true if (constraint_checker(v, c) rescue false)
            end
            return true if constraint.include? v
          when Range
            return true if constraint.cover? v
          when Regexp
            return true if v =~ constraint
          else
            return true if v == constraint
        end
        false
      end

    end # Parameter

    module ParameterContainer

      module ClassMethods

        def parameter(options = {})
          if options.is_a? Hash
            return nil if options.keys.empty?
            param_def = options.shift
            name = param_def.first.to_s.to_sym
            default = param_def.last
            parameters[name] = Parameter.new(name, default) if parameters[name].nil?
            VALID_PARAMETER_KEYS.each { |key| parameters[name][key] = options[key] if options[key] }
          else
            parameters[options]
          end
        end

        protected

        def parameters
          @parameters ||= Hash.new
        end

      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      NO_VALUE = '##NAV##'

      def parameter(name, value = NO_VALUE)
        param_def = get_parameter_definition(name)
        return NO_VALUE unless param_def
        if value.equal? NO_VALUE
          param_value = parameters[name]
          param_def.parse(param_value)
        else
          return NO_VALUE unless param_def.valid_value?(value)
          parameters[name] = value
        end
      end

      def [](name)
        parameter(name)
      end

      def []=(name, value)
        parameter name, value
      end

      protected

      def parameters
        @parameters ||= Hash.new
      end

      def get_parameter_definition(name)
        self.class.parameter(name)
      end

    end # ParameterContainer

  end # Tools
end # Libis
