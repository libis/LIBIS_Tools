# encoding: utf-8
require 'open3'

module Libis
  module Tools

    # This module allows to run an external command safely and returns it's output, error messages and status.
    # The run method takes any number of arguments that will be used as command-line arguments. The method returns
    # a Hash with:
    # * :out => an array with lines that were printed on the external program's standard out.
    # * :err => an array with lines that were printed on the external program's standard error.
    # * :status => exit code returned by the external program.
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
      # @param [String] cmd program name
      # @param [Array<String>] opts optional list of command line arguments
      # @return [Hash] a Hash with:
      #         * :status (Integer) - the exit status of the command
      #         * :out (Array<String>) - the stdout output of the command
      #         * :err (Array<String>)- the stderr output of the command
      def self.run(cmd, *opts)
        result = {
            status: 999,
            out: [],
            err: []
        }
        begin
          input, output, error, thread = Open3.popen3(cmd, *opts)
          input.close
          error.each_line do |line|
            next if result[:err].size > 100
            result[:err] << line.chomp
            result[:err] << '.... <<< Extra messages skipped >>> ....' if result[:err] == 100
          end
          output.each_line do |line|
            next if result[:out].size > 100
            result[:out] << line.chomp
            result[:out] << '.... <<< Extra messages skipped >>> ....' if result[:out] == 100
          end
          result[:status] = thread.value.exitstatus rescue nil

        rescue StandardError => e
          result[:err] = [e.class.name, e.message]

        end

        result

      end
    end

  end
end
