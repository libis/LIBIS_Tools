# encoding: utf-8
require 'date'
require 'libis/tools/extend/struct'

module Libis
  module Tools

    class ParameterValidationError < RuntimeError;
    end
    class ParameterFrozenError < RuntimeError;
    end

    # noinspection RubyConstantNamingConvention
    Parameter = ::Struct.new(:name, :default, :datatype, :description, :constraint, :frozen, :options) do

      def initialize(*args)
        # noinspection RubySuperCallWithoutSuperclassInspection
        super(*args)
        self[:options] ||= {}
        self[:datatype] ||= guess_datatype
      end

      def dup
        new_obj = super
        # noinspection RubyResolve
        new_obj[:options] = Marshal.load(Marshal.dump(self[:options]))
        new_obj
      end

      def [](key)
        # noinspection RubySuperCallWithoutSuperclassInspection
        return super(key) if members.include?(key)
        self[:options][key]
      end

      def []=(key, value)
        # noinspection RubySuperCallWithoutSuperclassInspection
        return super(key, value) if members.include?(key)
        self[:options][key] = value
      end

      def self.from_hash(h)
        h.each { |k, v| self[k.to_s.to_sym] = v }
      end

      def to_h
        super.inject({}) do |hash, key, value|
          key == :options ? value.each { |k, v| hash[k] = v } : hash[key] = value
          hash
        end
      end

      TRUE_BOOL = %w'true yes t y 1'
      FALSE_BOOL = %w'false no f n 0'

      def parse(value = nil)
        result = value.nil? ? self[:default] : convert(value)
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

      private

      def guess_datatype
        self[:datatype] || case self[:default]
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
                             when Array
                               'array'
                             when Hash
                               'hash'
                             else
                               self[:default].class.name.downcase
                           end
      end

      def convert(v)
        case self[:datatype]
          when 'boolean', 'bool'
            return true if TRUE_BOOL.include?(v.to_s.downcase)
            return false if FALSE_BOOL.include?(v.to_s.downcase)
            raise ParameterValidationError, "No boolean information in '#{v.to_s}'. " +
                                              "Valid values are: '#{TRUE_BOOL.join('\', \'')}" +
                                              "' and '#{FALSE_BOOL.join('\', \'')}'."
          when 'string', nil
            return v.to_s
          when 'int'
            return Integer(v)
          when 'float'
            return Float(v)
          when 'datetime'
            return v.to_datetime if v.respond_to? :to_datetime
            return DateTime.parse(v)
          when 'array'
            return v if v.is_a?(Array)
            return v.split(/[,;|\s]+/) if v.is_a?(String)
            return v.to_a if v.respond_to?(:to_a)
          when 'hash'
            return v when v.is_a?(Hash)
                       return Hash[(0...v.size).zip(v)] when v.is_a?(Array)
          else
            raise ParameterValidationError, "Datatype not supported: '#{self[:datatype]}'"
        end
        nil
      end

      def check_constraint(v, constraint = nil)
        constraint ||= self[:constraint]
        return if constraint.nil?
        unless constraint_checker(v, constraint)
          raise ParameterValidationError, "Value '#{v}' is not allowed (constraint: #{constraint})."
        end
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

        def parameter_defs
          return @parameters if @parameters
          @parameters = Hash.new
          begin
            self.superclass.parameter_defs.
                each_with_object(@parameters) do |(name, param), hash|
              hash[name] = param.dup
            end
          rescue NoMethodError
            # ignored
          end
          @parameters
        end

        def parameter(options = {})
          return self.parameter_defs[options] unless options.is_a? Hash
          return nil if options.keys.empty?
          param_def = options.shift
          name = param_def.first.to_s.to_sym
          default = param_def.last
          param = (self.parameter_defs[name] ||= Parameter.new(name, default))
          options[:default] = default
          options.each { |key, value| param[key] = value if value }
          param
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
          if param_def[:frozen]
            raise ParameterFrozenError, "Parameter '#{param_def[:name]}' is frozen in '#{self.class.name}'"
          end
          parameters[name] = value
        end
      end

      def [](name)
        parameter(name)
      end

      def []=(name, value)
        parameter name, value
      rescue ParameterFrozenError
        # ignored
      end

      protected

      def parameters
        @parameter_values ||= Hash.new
      end

      def get_parameter_definition(name)
        self.class.parameter_defs[name]
      end

    end # ParameterContainer

  end # Tools
end # Libis
