# encoding: utf-8

require 'digest'

module LIBIS
  module Tools

    # Common interface for checksum calculations.
    #
    # Supported checksum algortihms are MD5, RMD160, SHA-1, SHA-2 (256, 384 and 512-bit versions). All methods are
    # available on the class and on the instance. The instance has to be initialized with a checksum algorithm and
    # therefore the instance methods do not have to specify the checksum type.
    #
    class Checksum
      CHECKSUM_TYPES = [:MD5, :RMD160, :SHA1, :SHA256, :SHA384, :SHA512]

      # Create instance for a given checksum algorithm.
      #
      # @param [Symbol] type checksum algorithm; one of {#CHECKSUM_TYPES}
      def initialize(type)
        @hasher = self.class.get_hasher(type)
      end

      # Calculate binary digest of a file.
      #
      # @param [String] file_path path of the file to calculate the digest for
      def digest(file_path)
        @hasher.file(file_path).digest!
      end

      # Calculate the hexadecimal digest of a file.
      # @param (see #digest)
      def hexdigest(file_path)
        @hasher.file(file_path).hexdigest!
      end

      # Calculate the base64 digest of a file.
      # @param (see #digest)
      def base64digest(file_path)
        @hasher.file(file_path).base64digest!
      end

      # Calculate the binary digest of a file.
      # @param (see #digest)
      # @param (see #initialize)
      def self.digest(file_path, type)
        new(type).digest(file_path)
      end

      # Calculate the hexadecimal digest of a file.
      # @param (see #digest)
      # @param (see #initialize)
      def self.hexdigest(file_path, type)
        new(type).hexdigest(file_path)
      end

      # Calculate the base64 digest of a file.
      # @param (see #digest)
      # @param (see #initialize)
      def self.base64digest(file_path, type)
        new(type).base64digest(file_path)
      end

      # Instatiate a Digest instance for access to low-level functionality
      # @param (see #initialize)
      def self.get_hasher(type)
        raise RuntimeError, "Checksum type '#{type}' not supported." unless CHECKSUM_TYPES.include? type
        Digest(type).new
      end

    end

  end
end
