require 'tty-prompt'
require 'tty-config'
require 'pastel'

module Libis
  module Tools
    module Cli
      module Helper

        module ClassMethods

          def exit_on_failure?
            true
          end

        end

        def self.included(base)
          base.extend(ClassMethods)
        end

        attr_reader :prompt, :config, :pastel, :config_file_prefix

        def initialize(*args)
          @prompt = TTY::Prompt.new
          @config = TTY::Config.new
          @pastel = Pastel.new
          @config.append_path Dir.home
          @config_file_prefix = '.tools.'
          prompt.warn "Default config file: #{config.filename}"
          super
        end

        protected

        private

        def index_of(list, value)
          i = list.index(value)
          i += 1 if i
          i || 1
        end

        def config_write(name = nil)
          set_config_name(name || new_config)
          unless get_config_name
            prompt.error 'Could not write the configuration file: configuration not set'
            return
          end
          config.write force: true
        end

        def config_read(name = nil)
          config.filename = name ?
                                "#{config_file_prefix}#{name}" :
                                select_config_file(with_new: false)
          unless get_config_name
            prompt.error 'Could not read the configuration file: configuration not set'
            return
          end
          config.read
        rescue TTY::Config::ReadError
          prompt.error('Could not read the configuration file.')
          exit
        end

        def toggle_config(field)
          config.set(field, value: !config.fetch(field))
        end

        def get_config_name
          return $1 if get_config_file.match(config_file_regex)
          nil
        end

        def get_config_file
          config.filename
        end

        def config_file_regex(with_ext: false)
          /^#{Regexp.quote(config_file_prefix)}(.+)#{Regexp.quote(config.extname) if with_ext}$/
        end

        def set_config_name(name)
          config.filename = "#{config_file_prefix}#{name}" if name && !name.empty?
        end

        def set_config_file(name)
          config.filename = name if name && !name.empty?
        end

        def select_config_file(*args)
          "#{config_file_prefix}#{select_config_name *args}"
        end

        def select_config_name(with_new: true, force_select: false)
          current_cfg = get_config_name
          return current_cfg if !force_select && current_cfg

          cfgs = []
          cfgs << {
              name: '-- new configuration --',
              value: -> do
                new_config
              end
          } if with_new
          cfgs += Dir.glob(File.join(Dir.home, "#{config_file_prefix}*")).reduce([]) do |a, x|
            a.push($1) if File.basename(x).match(config_file_regex(with_ext: true))
            a
          end

          return nil if cfgs.empty?

          prompt.select '[ Select config menu ]', cfgs, default: index_of(cfgs, current_cfg), filter: true
        end

        def new_config
          while true
            name = prompt.ask('Enter a name for the configuration:', modify: :trim)
            return name unless File.exist?(File.join(Dir.home, "#{config_file_prefix}#{name}#{config.extname}")) &&
                !prompt.yes?("Configuration '#{name}' already exists. Overwrite?")
          end
        end

        def ask(question, field, bool: false, enum: nil, default: nil, mask: false, if_empty: false)
          cmd, args, opts = :ask, [question], {}
          default ||= config.fetch(field)
          if enum
            cmd = :select
            args << enum
            # Change default to its index in the enum
            default = index_of(enum, default)
            # Force the question if the supplied value is not valid
            config.delete field unless !if_empty || enum.include?(config.fetch field)
          end
          cmd = :mask if mask
          opts[:default] = config.fetch(field)
          opts[:default] = default if default
          cmd = (opts[:default] ? :yes? : :no?) if bool
          config.set(field, value: prompt.send(cmd, *args, opts)) unless if_empty && config.fetch(field)
        end

        def tree_select(path, question: nil, file: false, page_size: 22, filter: true, cycle: false, create: false,
                        default_choices: nil)
          path = Pathname.new(path) unless path.is_a? Pathname

          return path unless path.exist?
          path = path.realpath

          dirs = path.children.select(&:directory?).sort
          files = file ? path.children.select(&:file?).sort : []

          choices = []
          choices << {name: "Folder: #{path}", value: path, disabled: file ? '' : false}
          choices += default_choices if default_choices
          choices << {name: '-- new directory --', value: -> do
            new_name = prompt.ask('new directory name:', modify: :trim, required: true)
            new_path = path + new_name
            FileUtils.mkdir(new_path.to_path)
            new_path
          end
          } if create

          choices << {name: "-- new file --", value: -> do
            new_name = prompt.ask('new file name:', modify: :trim, required: true)
            path + new_name
          end
          } if file && create

          choices << {name: '[..]', value: path.parent}

          dirs.each {|d| choices << {name: "[#{d.basename}]", value: d}}
          files.each {|f| choices << {name: f.basename.to_path, value: f}}

          question ||= "Select #{'file or ' if files}directory"
          selection = prompt.select question, choices,
                                    per_page: page_size, filter: filter, cycle: cycle, default: file ? 2 : 1

          return selection unless selection.is_a? Pathname
          return selection.to_path if selection == path || selection.file?

          tree_select selection, question: question, file: file, page_size: page_size, filter: filter,
                      cycle: cycle, create: create, default_choices: default_choices
        end

      end
    end
  end
end