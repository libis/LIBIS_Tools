# encoding: utf-8

module LIBIS
  module Tools

    module Command
      def self.run(cmd, *opts)
        out = StringIO.new
        err = StringIO.new
        $stdout = out
        $stderr = err
        status = system cmd, *opts
        return {status: status, out: out.string, err: err.string}
      ensure
        $stdout = STDOUT
        $stderr = STDERR
      end
    end

  end
end
