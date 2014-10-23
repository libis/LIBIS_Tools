# encoding: utf-8
require 'date'
require 'time'
require 'libis/tools/extend/struct'

module LIBIS
  module Tools

    # noinspection RubyConstantNamingConvention
    Parameter = ::Struct.new(:name, :default, :datatype, :description, :propagate_to, :constraint) do

      TRUE_BOOL = %w'true yes t y 1'
      FALSE_BOOL = %w'false no f n 0'

      def parse(value)
        return send(:default) if value.nil?
        dtype = guess_datatype.to_s.downcase
        result = convert(dtype, value)
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
          else
            send(:default).class.name
        end
      end

      private

      def convert(dtype, v)
        case dtype
          when 'date'
            return Time.parse(v).to_date
          when 'time'
            return Time.parse(v).to_time
          when 'datetime'
            return Time.parse(v).to_datetime
          when 'boolean', 'bool'
            return true if TRUE_BOOL.include?(v.to_s.downcase)
            return false if FALSE_BOOL.include?(v.to_s.downcase)
            raise ArgumentError, "No boolean information in '#{v.to_s}'. Valid values are: '#{TRUE_BOOL.join('\', \'')}' and '#{FALSE_BOOL.join('\', \'')}'."
          when 'string'
            return v.to_s.gsub('%s', Time.now.strftime('%Y%m%d%H%M%S'))
          else
            raise RuntimeError, "Datatype not supported: 'dtype'"
        end
      end

      def check_constraint(v, constraint = nil)
        constraint ||= send(:constraint)
        return if constraint.nil?
        case constraint
          when Regexp
            return if v =~ constraint
          when Array
            constraint.each do |c|
              return if (check_constraint(v, c) rescue false)
            end
            return if constraint.include? v
          when Range
            return if constraint.cover? v
          else
            return if v == constraint
        end
        raise ArgumentError, "Value '#{v}' is not allowed (constraint: #{constraint})."
      end

    end # Parameter

    module ParameterContainer

      VALID_PARAMETER_KEYS = [:name, :value, :default, :datatype, :description, :propagate_to, :constraint]

      def parameters
        @parameters ||= {}
      end

      def parameter(options = {})
        param_def = options.shift
        name = param_def.first.to_s.to_sym
        default = param_def.last
        parameters[name] = Parameter.new(name, default) if parameters[name].nil?
        VALID_PARAMETER_KEYS.each { |key| parameters[name][key] = options[key] if options[key] }
      end

      def get_parameter(name)
        parameters[name]
      end

      def get_parameters
        ancestors.reverse.inject({}) do |hash, ancestor|
          hash.merge! ancestor.parameters rescue nil
          hash
        end
      end

      def default_values
        get_parameters.inject({}) do |hash, parameter|
          hash[parameter.first] = parameter.last[:default]
          hash
        end
      end

      def valid_value?(name, value)
        get_parameters[name].valid_value?(value) rescue false
      end

    end # ParameterContainer

  end # Tools
end # LIBIS
