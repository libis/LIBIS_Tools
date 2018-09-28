require 'thor'
require 'tty-prompt'
require 'tty-config'

require 'libis/tools/cli/cli_helper'
require 'libis/tools/cli/reorg'

module Libis
  module Tools

    class CommandLine < Thor

      include Cli::Helper
      include Cli::Reorg

      def reorg
        super
      end

    end

  end
end
