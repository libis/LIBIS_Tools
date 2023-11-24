# encoding: utf-8
require 'timeout'

module Libis
  module Tools

    # This module allows to run an external command safely and returns it's output, error messages and status.
    # The run method takes any number of arguments that will be used as command-line arguments. The method returns
    # a Hash with:
    # * :out => an array with lines that were printed on the external program's standard out.
    # * :err => an array with lines that were printed on the external program's standard error.
    # * :status => exit code returned by the external program.
    # * :timeout => true if the command was terminated due to a timeout.
    # * :pid => pid of the command (in case <pid>.log files need to be cleaned up)
    #
    # Optionally an option hash can be appended to the list of arguments with:
    # * :stdin_data => values sent to the command's standard input (optional, nothing sent if not present)
    # * :binmode => if present and true, will set the IO communication to binary data
    # * :timeout => if specified, SIGTERM signal is sent to the command after the number of seconds
    # * :signal => Signal sent to the command instead of the default SIGTERM
    # * :kill_after => if specified, SIGKILL signal is sent aftern the number of seconds if command is still running
    #             after initial signal was sent
    # * any other options will be handed over to the spawn command (e.g. pgroup)
    #
    # Examples:
    #
    #     require 'libis/tools/command'
    #     result = ::Libis::Tools::Command.run('ls', '-l', File.absolute_path(__FILE__))
    #     p result # => {out: [...], err: [...], status: 0}
    #
    #     require 'libis/tools/command'
    #     include ::Libis::Tools::Command
    #     result = run('ls', '-l', File.absolute_path(__FILE__))
    #     p result # => {out: [...], err: [...], status: 0}
    #
    # Note that the Command class uses Open3#popen3 internally. All arguments supplied to Command#run are passed to
    # the popen3 call. Unfortunately some older JRuby versions have some known issues with popen3. Please use and
    # test carefully in JRuby environments.
    module Command

      # Run an external program and return status, stdout and stderr.
      #
      #
      # @param [Array<String>] cmd command name optionally prepended with env and appended with command-line arguments
      # @return [Hash] a Hash with:
      #         * :status (Integer) - the exit status of the command
      #         * :out (Array<String>) - the stdout output of the command
      #         * :err (Array<String>)- the stderr output of the command
      #         * :timeout(Boolean) - if true, the command did not return in time
      #         * :pid(Integer) - the command's processID
      def self.run(*cmd, **spawn_opts)

        opts = {
            :stdin_data => spawn_opts.delete(:stdin_data) || '',
            :binmode => spawn_opts.delete(:binmode) || false,
            :timeout => spawn_opts.delete(:timeout),
            :signal => spawn_opts.delete(:signal) || :TERM,
            :kill_after => spawn_opts.delete(:kill_after),
        }
        in_r, in_w = IO.pipe
        out_r, out_w = IO.pipe
        err_r, err_w = IO.pipe
        in_w.sync = true

        if opts[:binmode]
          in_w.binmode
          out_r.binmode
          err_r.binmode
        end

        spawn_opts[:in] = in_r
        spawn_opts[:out] = out_w
        spawn_opts[:err] = err_w

        result = {
            :pid => nil,
            :status => nil,
            :out => [],
            :err => [],
            :timeout => false,
        }

        out_reader = nil
        err_reader = nil
        wait_thr = nil

        begin
          Timeout.timeout(opts[:timeout]) do
            result[:pid] = spawn(*cmd, spawn_opts)
            wait_thr = Process.detach(result[:pid])
            in_r.close
            out_w.close
            err_w.close

            out_reader = Thread.new {out_r.read}
            err_reader = Thread.new {err_r.read}

            in_w.write opts[:stdin_data]
            in_w.close

            result[:status] = wait_thr.value
          end

        rescue Timeout::Error
          result[:timeout] = true
          pid = spawn_opts[:pgroup] ? -result[:pid] : result[:pid]
          Process.kill(opts[:signal], pid)
          if opts[:kill_after]
            unless wait_thr.join(opts[:kill_after])
              Process.kill(:KILL, pid)
            end
          end

        rescue StandardError => e
          result[:err] = [e.class.name, e.message]

        ensure
          result[:status] = wait_thr.value.exitstatus if wait_thr
          result[:out] += out_reader.value.split("\n").map(&:chomp) if out_reader
          result[:err] += err_reader.value.split("\n").map(&:chomp) if err_reader
          out_r.close unless out_r.closed?
          err_r.close unless err_r.closed?
        end

        result

      end

    end

  end
end
