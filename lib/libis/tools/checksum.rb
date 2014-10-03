# encoding: utf-8

require 'digest'

module LIBIS
  module Tools

    class Checksum
      CHECKSUM_TYPES = [:MD5, :RMD160, :SHA1, :SHA256, :SHA384, :SHA512]
      BUF_SIZE = 10240

      def self.digest(file_path, type)
        get_hasher(type).file(file_path).digest
      end

      def self.hexdigest(file_path, type)
        get_hasher(type).file(file_path).hexdigest
      end

      def self.base64digest(file_path, type)
        get_hasher(type).file(file_path).base64digest
      end
      def self.get_hasher(type)
        raise RuntimeError, "Checksum type '#{type}' not supported." unless CHECKSUM_TYPES.include? type
        ::Digest(type).new
      end

    end

  end
end
