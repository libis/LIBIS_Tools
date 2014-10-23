# encoding: utf-8

module LIBIS
  module Tools

    module Command
      def self.run(cmd, *opts)
        # old_out = $stdout
        # old_err = $stderr
        # out = StringIO.new
        # err = StringIO.new
        # $stdout = out
        # $stderr = err
        # status = system cmd, *opts
        # old_out.puts "cmd: #{cmd}\nopts: #{opts}\nstatus: #{status}\nout: #{out.string}\nerr: #{err.string}"
        # return {status: status, out: out.string, err: err.string}
        return { out: %x(#{cmd} #{opts.join(' ')}) }

      ensure
        # $stdout = old_out
        # $stderr = old_err
      end
    end

  end
end
