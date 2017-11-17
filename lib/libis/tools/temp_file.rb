require 'libis/tools/extend/empty'

module Libis
  module Tools

    module TempFile

      def self.dir
        Dir.tmpdir
      end

      def self.name(prefix = '', suffix = '', _dir = nil)
        _dir ||= dir
        t = Time.now.strftime('%Y%m%d')
        t = '_' + t unless prefix.empty?
        File.join(_dir, "#{prefix}#{t}_#{$$}_#{rand(0x100000000).to_s(36)}#{suffix}".freeze)
      end

      def self.file(prefix = '', suffix = '', dir = nil)
        f = File.open(name(prefix, suffix, dir), 'w')

        def f.unlink
          File.unlink self
        end

        def f.delete
          File.delete self
        end

        if block_given?
          x = yield(f)
          f.close
          f.delete
          return x
        else
          return f
        end
      end
    end

  end
end
