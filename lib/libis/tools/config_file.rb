# encoding: utf-8
require 'singleton'
require 'yaml'
require 'erb'

require 'libis/tools/deep_struct'

module Libis
  module Tools

    # The ConfigFile class is a convenience class for interfacing with YAML configuration files. These files can
    # contain ERB statements. An initial hash or file can be loaded during initialization. The class supports loading
    # and saving of files, but note that any ERB statements in the file are lost by performing such a round trip.
    # The class is derived from the DeepStruct class and therefore supports nested hashes and arrays and supports
    # the OpenStruct style of accessors.
    #
    # The parameters can be accessed by getter/setter method or using the Hash syntax:
    #
    #         require 'libis/tools/config_file'
    #         cfg_file = ::Libis::Tools::ConfigFile.new
    #         cfg_file << {foo: 'bar'}
    #         cfg_file.my_value = 10
    #         p cfg_file[:my_value] # => 10
    #         cfg_file{:my_text] = 'abc'
    #         p cfg_file['my_text'] # => 'abc'
    #         p cfg_file.to_hash # => { :foo => 'bar', 'my_value' => 10, :my_text => 'abc' }
    #         cfg >> 'my_config.yml'
    #
    class ConfigFile < DeepStruct

      # Create a new ConfigFile instance. The optional argument can either be a Hash or a String. The argument is
      # passed to the {#<<} method after initialization.
      #
      # @param [String,Hash] file_or_hash optional String or Hash argument to initialize the data.
      def initialize(file_or_hash = nil, opt = {})
        super _file_to_hash(file_or_hash), opt
      end

      # Load configuration parameters from a YAML file or Hash.
      #
      # The YAML file can contain ERB syntax values that will be evaluated at loading time. Instead of a YAML file,
      # a Hash can be passed.
      #
      # Note that the method also yields the hash or absolute path to a given block. This is for data management of
      # derived classes such as ::Libis::Tools::Config.
      #
      # @param [String,Hash] file_or_hash optional String or Hash argument to initialize the data.
      def <<(file_or_hash, &block)
        _file_to_hash(file_or_hash, &block).each { |key, value| self[key] = value }
        self
      end

      # Save configuration parameters in a YAML file.
      #
      # @param [String] file path of the YAML file to save the configuration to.
      def >>(file)
        File.open(file, 'w') { |f| f.write to_hash.to_yaml }
      end

      protected

      def _file_to_hash(file_or_hash)
        return {} if file_or_hash.nil? || (file_or_hash.respond_to?(:empty?) && file_or_hash.empty?)
        hash = case file_or_hash
                 when Hash
                   yield file_or_hash if block_given?
                   file_or_hash
                 when String
                   return {} unless File.exist?(file_or_hash)
                   yield File.absolute_path(file_or_hash) if block_given?
                   # noinspection RubyResolve
                   begin
                   YAML.load(ERB.new(open(file_or_hash).read).result)
                   rescue Exception => e
                     raise RuntimeError, "Error loading YAML '#{file_or_hash}': #{e.message}"
                   end
                 else
                   {}
               end
        hash = {} unless hash.is_a? Hash
        hash
      end

    end
  end
end
