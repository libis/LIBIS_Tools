# encoding: utf-8

require 'digest'

module Libis
  module Tools

    # Common interface for checksum calculations.
    #
    # Supported checksum algortihms are MD5, RMD160 (not on JRuby), SHA-1, SHA-2 (256, 384 and 512-bit versions).
    # All methods are available on the class and on the instance. The instance has to be initialized with a checksum
    # algorithm and therefore the instance methods do not have to specify the checksum type.
    #
    class Checksum
      if defined? JRUBY_VERSION
        CHECKSUM_TYPES = [:MD5, :SHA1, :SHA256, :SHA384, :SHA512]
      else
        CHECKSUM_TYPES = [:MD5, :RMD160, :SHA1, :SHA256, :SHA384, :SHA512]
      end

      # Create instance for a given checksum algorithm.
      #
      # @param [Symbol] type checksum algorithm; one of {#CHECKSUM_TYPES}
      def initialize(type)
        @hasher = self.class.get_hasher(type)
      end

      # Calculate binary digest of a file.
      #
      # @param [String] file_path_or_string path of the file to calculate the digest for
      def digest(file_path_or_string)
        @hasher.file(file_path_or_string).digest!
      end

      # Calculate the hexadecimal digest of a file.
      # @param (see #digest)
      def hexdigest(file_path_or_string)
        @hasher.file(file_path_or_string).hexdigest!
      end

      # Calculate the base64 digest of a file.
      # @param (see #digest)
      def base64digest(file_path_or_string)
        @hasher.file(file_path_or_string).base64digest!
      end

      # Calculate the binary digest of a file.
      # @param (see #digest)
      # @param (see #initialize)
      def self.digest(file_path_or_string, type)
        new(type).digest(file_path_or_string)
      end

      # Calculate the hexadecimal digest of a file.
      # @param (see #digest)
      # @param (see #initialize)
      def self.hexdigest(file_path_or_string, type)
        new(type).hexdigest(file_path_or_string)
      end

      # Calculate the base64 digest of a file.
      # @param (see #digest)
      # @param (see #initialize)
      def self.base64digest(file_path_or_string, type)
        new(type).base64digest(file_path_or_string)
      end

      # Instatiate a Digest instance for access to low-level functionality
      # @param (see #initialize)
      def self.get_hasher(type)
        raise RuntimeError, "Checksum type '#{type}' not supported." unless CHECKSUM_TYPES.include? type
        Digest(type).new
      end

      private

      def hashit(file_path_or_string)
        @hasher.file(file_path_or_string)
      end

    end

  end
end
