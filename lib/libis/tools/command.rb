# encoding: utf-8
require 'open3'

module Libis
  module Tools

    module Command

      # Run an external program and return status, stdout and stderr.
      #
      #
      # @param [String] cmd program name
      # @param [Array<String>] opts optional list of command line arguments
      # @return [Hash] a Hash with:
      #         * +:status+ : the exit status of the command
      #         * +:out+ : the stdout output of the command
      #         * +:err+ : the stderr output of the command
      def self.run(cmd, *opts)
        result = {
            status: 999,
            out: [],
            err: []
        }
        begin
          Open3.popen3(cmd, *opts) do |_, output, error, thread|
            output = output.read
            error = error.read
            result[:out] = output.split("\n").map(&:chomp)
            result[:err] = error.split("\n").map(&:chomp)
            result[:status] = thread.value.exitstatus rescue nil
          end

        rescue StandardError => e
          result[err] = [e.class.name, e.message]

        end

        result

      end
    end

  end
end
