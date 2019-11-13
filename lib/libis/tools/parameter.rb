# encoding: utf-8
require 'date'
require 'libis/tools/extend/struct'
require 'concurrent/hash'

module Libis
  module Tools

    # Exception that will be raised when a parameter value does not pass the validation checks.
    class ParameterValidationError < RuntimeError;
    end

    # Exception that will be raised when an attempt is made to change the value of a frozen parameter.
    class ParameterFrozenError < RuntimeError;
    end

    # noinspection RubyConstantNamingConvention

    # A {Parameter} is like a class instance attribute on steroids. Contrary to regular attributes, {Parameter}s are
    # type-safe, can have a descriptive text explaining their use, a constraint that limits the values and any other
    # properties for an application to use for their needs.
    #
    # Parameters are inherited from base classes and can be overwritten without affecting the parameters in the parent
    # class. For instance, a regular parameter in the parent class can be given a fixed value in the child class by
    # giving it a default value and setting it's frozen property to true. The same paremter in the parent class
    # instances will still be modifieable. But the parameter in the child class instances will be frozen, even if
    # accessed via the methods on parent class.
    #
    # Important: the parameter will exist both on the class level as on the instance level, but the parameter on the
    # class level is the parameter definition as described in the {Parameter} class. On the instance level, there are
    # merely some parameter methods that access the parameter instance values with the help of the parameter definitions
    # on the class. The implementation of the parameter instances is dealt with by the {ParameterContainer} module.
    class Parameter < Struct.new(:name, :default, :datatype, :description, :constraint, :frozen, :options)

      # Create a Parameter instance.
      # @param [Array] args The values for:
      #     * name - Required. String for the name of the parameter. Any valid attribute name is acceptable.
      #     * default value - Any value. Will be coverted to the given datatype if present. Default is nil.
      #     * datatype - String. One of: bool, string, int, float, datetime, array, hash. If omitted it will be derived
      #       from the default value or set to the default 'string'.
      #     * description - String describing the parameter's use.
      #     * constraint - Array, Range, RegEx or single value. Default is nil meaning no constraint.
      #     * frozen - Boolean. Default is false; if true the parameter value cannot be changed from the default value.
      #     * options - Any Hash. It's up to the applcation to interprete and use this info.
      #    datatype can be omitted if the type can be derived from the
      def initialize(*args)
        super(*args)
        self[:options] ||= {}
        self[:datatype] ||= guess_datatype
      end

      # Duplicates the parameter
      def dup
        new_obj = super
        # noinspection RubyResolve
        new_obj[:options] = Marshal.load(Marshal.dump(self[:options]))
        new_obj
      end

      # Merges other parameter data into the current parameter
      # @param [::Libis::Tools::Parameter] other parameter definition to copy properties from
      def merge!(other)
        other.each do |k, v|
          if k == :options
            self[:options].merge!(v)
          else
            self[k] = v
          end
        end
        self
      end

      # Retrieve a specific property of the parameter.
      # If not found in the regular properties, the options Hash is scanned for the property.
      # @param [Symbol] key name of the property
      def [](key)
        return super(key) if members.include?(key)
        self[:options][key]
      end

      # Set a property of the parameter.
      # If the property is not one of the regular properties, the property will be set in the options Hash.
      # @param (see #[])
      # @param [Object] value value for the property. No type checking happens on this value
      def []=(key, value)
        return super(key, value) if members.include?(key)
        self[:options][key] = value
      end

      # Convience method to create a new {Parameter} from a Hash.
      # @param [Hash] h Hash with parameter definition properties
      def self.from_hash(h)
        h.each { |k, v| self[k.to_s.to_sym] = v }
      end

      # Dumps the parameter properties into a Hash.
      # The options properties are merged into the hash. If you do not want that, use Struct#to_h instead.
      #
      # @return [Hash] parameter definition properties
      def to_h
        super.inject({}) do |hash, key, value|
          key == :options ? value.each { |k, v| hash[k] = v } : hash[key] = value
          hash
        end
      end

      # Valid input strings for boolean parameter value, all converted to 'true'
      TRUE_BOOL = %w'true yes t y 1'
      # Valid input strings for boolean parameter value, all converted to 'false'
      FALSE_BOOL = %w'false no f n 0'

      # Parse any value and try to convert to the correct datatype and check the constraints.
      # Will throw an exception if not valid.
      # @param [Object] value Any value to parse, strings are best supported.
      # @return [Object] checked and converted value
      def parse(value = nil)
        result = value.nil? ? self[:default] : convert(value)
        check_constraint(result)
        result
      end

      # Parse any value and try to convert to the correct datatype and check the constraints.
      # Will return false if not valid, true otherwise.
      # @param [Object] value Any value to check
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
        case self[:datatype].to_s.downcase
        when 'boolean', 'bool'
          return true if TRUE_BOOL.include?(v.to_s.downcase)
          return false if FALSE_BOOL.include?(v.to_s.downcase)
          raise ParameterValidationError, "No boolean information in '#{v.to_s}'. " +
              "Valid values are: '#{TRUE_BOOL.join('\', \'')}" +
              "' and '#{FALSE_BOOL.join('\', \'')}'."
        when 'string', 'nil'
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
          # Alternatavely:
          # return JSON.parse(v) if v.is_a?(String)
          return v.to_a if v.respond_to?(:to_a)
        when 'hash'
          return v if v.is_a?(Hash)
          return Hash[(0...v.size).zip(v)] if v.is_a?(Array)
          return JSON.parse(v) if v.is_a?(String)
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

    # To use the parameters a class should include the ParameterContainer module and add parameter
    # statements to the body of the class definition.
    #
    # Besides enabling the {::Libis::Tools::ParameterContainer::ClassMethods#parameter parameter} class method to
    # define parameters, the module adds the class method
    # {::Libis::Tools::ParameterContainer::ClassMethods#parameter_defs parameter_defs} that will return
    # a Hash with parameter names as keys and their respective parameter definitions as values.
    #
    # On each class instance the {::Libis::Tools::ParameterContainer#parameter parameter} method is added and serves
    # as both getter and setter for parameter values.
    # The methods {::Libis::Tools::ParameterContainer#[] []} and {::Libis::Tools::ParameterContainer#[]= []=} serve as
    # aliases for the getter and setter calls.
    #
    # Additionally two protected methods are available on the instance:
    # * {::Libis::Tools::ParameterContainer#parameters parameters}: returns the Hash that keeps track of the current
    #   parameter values for the instance.
    # * {::Libis::Tools::ParameterContainer#get_parameter_definition get_parameter_defintion}: retrieves the parameter
    #   definition from the instance's class for the given parameter name.
    #
    # Any class that derives from a class that included the ParameterContainer module will automatically inherit all
    # parameter definitions from all of it's base classes and can override any of these parameter definitions e.g. to
    # change the default values for the parameter.
    #
    module ParameterContainer

      # Methods created on class level.
      module ClassMethods

        # Get a list of all parameter definitions.
        # The list is initialized with duplicates of the parameter definitions of the parent class and
        # each new parameter definition updates or appends the list.
        # @return [Hash] with parameter names as keys and {Parameter} instance as value.
        def parameter_defs
          return @parameters if @parameters
          @parameters = ::Concurrent::Hash.new
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

        # DSL method that allows creating parameter definitions on the class level.
        #
        # It takes only one mandatory argument which is a Hash. The first entry is interpreted as '<name>: <default>'.
        # The name for the parameter should be unique and the default value can be any value
        # of type TrueClass, FalseClass, String, Integer, Float, Date, Time, DateTime, Array, Hash or nil.
        #
        # The second up to last Hash entries are optional properties for the parameter. These are:
        # * datatype: the type of values the parameter will accept. Valid values are:
        #   * 'bool' or 'boolean'
        #   * 'string'
        #   * 'int'
        #   * 'float'
        #   * 'datetime'
        #   * 'array'
        #   * 'hash'
        #   Any other value will raise an Exception when the parameter is used. The value is case-insensitive and
        #   if not present, the datatype will be derived from the default value with 'string' being the default for
        #   NilClass. In any case the parameter will try its best to convert supplied values to the proper data type.
        #   For instance, an Integer parameter will accept 3, 3.1415, '3' and Rational(10/3) as valid values and
        #   store them as the integer value 3. Likewise DateTime parameters will try to interprete date and time strings.
        # * description: any descriptive text you want to add to clarify what this parameter is used for.
        #   Any tool can ask the class for its parameters and - for instance - can use this property to provide help
        #   in a GUI when asking the user for input.
        # * constraint: adds a validation condition to the parameter. The condition value can be:
        #   * an array: only values that convert to a value in the list are considered valid.
        #   * a range: only values that convert to a value in the given range are considered valid.
        #   * a regular expression: only values that match the regular expression are considered valid.
        #   * a string: only values that are '==' to the constraint are considered valid.
        # * frozen: if set to true, prevents the class instance to set the parameter to any value other than
        #   the default. Mostly useful when a derived class needs a parameter in the parent class to be set to a
        #   specific value. Setting a value on a frozen parameter with the 'parameter(name,value)' method throws a
        #   {::Libis::Tools::ParameterFrozenError}.
        # * options: a hash with any additional properties that you want to associate to the parameter. Any key-value pair in this
        #   hash is added to the retrievable properties of the parameter. Likewise any property defined, that is not in the list of
        #   known properties is added to the options hash. In this aspect the ::Libis::Tools::Parameter class behaves much like an
        #   OpenStruct even though it is implemented as a Struct.
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

      # @!visibility private
      def self.included(base)
        base.extend(ClassMethods)
      end

      # Special constant to indicate a parameter has no value set. Nil cannot be used as it is a valid value.
      NO_VALUE = '##NAV##'

      # Getter/setter for parameter instances
      # With only one argument (the parameter name) it returns the current value for the parameter, but the optional
      # second argument will cause the method to set the parameter value. If the parameter is not available or
      # the given value is not a valid value for the parameter, the method will return the special constant
      # {::Libis::Tools::ParameterContainer::NO_VALUE NO_VALUE}.
      #
      # Setting a value on a frozen parameter with the 'parameter(name,value)' method throws a
      # {::Libis::Tools::ParameterFrozenError} exception.
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

      # Alias for the {#parameter} getter.
      def [](name)
        parameter(name)
      end

      # Alias for the {#parameter} setter.
      # The only difference is that in case of a frozen parameter, this method silently ignores the exception,
      # but the default value still will not be changed.
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
