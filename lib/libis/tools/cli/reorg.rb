require 'libis/tools/spreadsheet'
require 'awesome_print'

module Libis
  module Tools
    module Cli
      module Reorg

        # noinspection RubyExpressionInStringInspection
        DEFAULT_CONFIG = {
            base: '.',
            filter: '^(.*)$',
            expression: 'target/#{file_name}',
            action: 'move',
            overwrite: false,
            interactive: false,
            report: nil,
            dummy: false,
            config: nil,
            unattended: false
        }

        # noinspection RubyStringKeysInHashInspection
        VALID_ACTIONS = {
            'move' => 'moved',
            'copy' => 'copied',
            'link' => 'linked'
        }

        STRING_CONFIG = {
            base: "Source Directory to organize",
            filter: "File matching filter",
            expression: "New file path expression",
            action: "Action to perform",
            overwrite: "Overwite target files if newer",
            interactive: "Ask for action on changed files",
            report: "Report file",
            dummy: "Perform phantom actions (not affecting files)",
            config: "Load saved configuration parameters"
        }

        REQ_HEADERS = {term: 'Term'}
        OPT_HEADERS = {pid: 'Pid', filename: 'File'}

        def self.included(klass)
          klass.class_exec do
            def klass.description(field)
              "#{STRING_CONFIG[field]}." + (DEFAULT_CONFIG[field].nil? ? '' : " default: #{DEFAULT_CONFIG[field]}")
            end

            desc 'reorg [options]', 'Reorganize files'
            long_desc <<-DESC
      
            'reorg [options]' will reorganize files based on the name of the files.

            The base directory will be scanned for files that match the FILTER regular expression. For each matching
            file, an action will be performed. The outcome of the action is determined by the expression that is given.

            The expression will be evaluated as a Ruby string expression and supports string interpolation in the form
            '\#{<thing>}', where <thing> can be any of:

            . $x : refers to the x-th group in the FILTER. Groups are numbered by the order of the opening '('

            . file_name : the original file name

            The action that will be performed on the action depens on the configured ACTION. The valid ACTIONs are; 
            'move', copy' and 'link'. Please note that in the latter case only the files will be soft-linked and any 
            directory in the target path will be created. The tool will therefore never create soft-links to directories. 
            The soft-links are created with an absolute reference path. This allows you to later move and rename the 
            soft-links later as you seem fit without affecting the source files. You could for instance run this tool on 
            the soft-links with the 'move' action to do so.

            By default, if the target file already exists, the file ACTION will not be performed. The '--overwrite'
            option will cause the tool to compare the file dates and checksums of source and target files in that case.
            Only if the checksums are different and the source file has a more recent modification date, the target file 
            will be overwritten. If you want to be asked for overwrite confirmation for each such file, you can add the 
            '--interactive' option.

            The tool can generate a report on all the file actions that have been performed. To do so, specify a file
            name for the '--report' option. The format of the report will be determined by the file extension you supply:

            - *.csv : comma-separated file

            - *.tsv : tab-separated file

            - *.yml : YAML file

            - *.xml : XML file

            By adding the --dummy option, you can test your settings without performing the real actions on the file.
            The tool will still report on its progress as if it would perform the actions.

            All the options can be saved into a configuration file to be reused later. You can specify which 
            configuration file you want to use with the '--config' option. If you specify a configuration file, the tool
            will first load the options from the configuration file and then process the command-line options. The 
            command-line options therefore have priority over the options in the configuration file.

            By default the tool allows you to review the activated options and gives you the opportunity to modify them
            before continuing of bailing out. If you are confident the settings are fine, you can skip this with the
            '--unatttended' option. Handle with care!

            Unless you have specified the '--unattended' options, you will be presented with a menu that allows you to
            change the configuration parameters, run the tool with the current config or bail out.

            DESC

            method_option :base, aliases: '-b',
                          desc: description(:base)
            method_option :filter, aliases: '-f',
                          desc: description(:filter)
            method_option :expression, aliases: '-e',
                          desc: description(:expression)

            method_option :action, aliases: '-a', enum: VALID_ACTIONS.keys,
                          desc: description(:action)
            method_option :overwrite, aliases: '-o', type: :boolean,
                          desc: description(:overwrite)
            method_option :interactive, aliases: '-i', type: :boolean,
                          desc: description(:interactive)

            method_option :report, aliases: '-r', banner: 'FILE',
                          desc: description(:report)

            method_option :dummy, aliases: '-d', type: :boolean,
                          desc: description(:dummy)

            method_option :config, aliases: '-c', type: :string,
                          desc: description(:config)

            method_option :unattended, aliases: '-u', type: :boolean,
                          desc: description(:unattended)

          end

        end

        def reorg
          @config_file_prefix = '.reorg.'

          # return config_write

          DEFAULT_CONFIG.each {|key, value| config.set(key, value: value) unless value.nil?}
          config_read(options[:config]) if options[:config]
          DEFAULT_CONFIG.each {|key, _| config.set(key, value: options[key]) if options.has_key?(key.to_s)}
          run_menu unless options[:unattended]
          do_reorg
        end

        protected

        def run_menu

          begin
            choices = []

            choices << {name: "Configuration editor",
                        value: -> {config_menu; 1}
            }

            choices << {name: "Run", value: nil}
            choices << {name: "Exit", value: -> {exit}}

            selection = prompt.select "[ LIBIS Tool - ReOrg ]",
                                      choices, cycle: true, default: 1

          end until selection.nil?

        end

        def print_field(field)
          value = config.fetch(field)
          value = 'Yes' if value.is_a?(TrueClass)
          value = 'No' if value.is_a?(FalseClass)
          "#{STRING_CONFIG[field]} : #{pastel.green(value)}"
        end

        def config_menu

          selection = 1

          begin
            choices = []
            choices << {name: print_field(:base),
                        value: -> do
                          config.set :base,
                                     value: tree_select(config.fetch(:base) || '.', question: 'Select source directory:')
                          1
                        end
            }
            choices << {name: print_field(:filter),
                        value: -> {ask 'File filter regex:', :filter; 2}
            }
            choices << {name: print_field(:expression),
                        value: -> {ask 'New path expression:', :expression; 3}
            }
            choices << {name: print_field(:action),
                        value: -> {ask 'Action:', :action, enum: VALID_ACTIONS.keys; 4}
            }
            choices << {name: print_field(:overwrite),
                        value: -> {toggle_config(:overwrite); prompt.say print_field(:overwrite); 5}
            }
            choices << {name: print_field(:interactive),
                        value: -> {toggle_config(:interactive); prompt.say print_field(:interactive); 6}
            }
            choices << {name: print_field(:report),
                        value: -> do
                          report = config.fetch(:report)
                          default = '.'
                          default = File.dirname(report) if report && File.file?(report)
                          report = tree_select(default, question: 'Select source directory',
                                               file: true, create: true,
                                               default_choices: [{name: "-- no report --", value: nil}])
                          if report
                            config.set(:report, value: report)
                          else
                            config.delete(:report)
                          end
                          7
                        end
            }
            choices << {name: print_field(:dummy),
                        value: -> {toggle_config(:dummy); prompt.say print_field(:dummy); 8}
            }
            choices << {name: "-- save configuration '#{get_config_name}' --",
                        value: -> {config_write get_config_name; 9}
            } if get_config_name
            choices << {name: "-- save to new configuration --",
                        value: -> {config_write new_config; 10}
            }
            choices << {name: "-- read configuration --",
                        value: -> {config_read; 11}
            }
            choices << {name: "-- return to main menu --", value: nil}

            selection = prompt.select "[ Configuration menu ]",
                                      choices, per_page: 20, cycle: true, default: selection

          end until selection.nil?

        end

        def do_reorg
          prompt.ok 'This can take a while. Please sit back and relax, grab a cup of coffee, have a quick nap or read a good book ...'

          # keeps track of folders created
          require 'set'
          target_dir_list = Set.new

          open_report

          require 'fileutils'
          count = {move: 0, duplicate: 0, update: 0, reject: 0, skipped_dir: 0, unmatched_file: 0}

          base_dir = config.fetch(:base)
          parse_regex = Regexp.new(config.fetch(:filter))
          path_expression = "#{config.fetch(:expression)}"
          dummy_operation = config.fetch(:dummy)
          interactive = config.fetch(:interactive)
          overwrite = config.fetch(:overwrite)
          file_operation = config.fetch(:action)
          Dir.new(base_dir).entries.each do |file_name|
            next if file_name =~ /^\.\.?$/
            entry = File.join(File.absolute_path(base_dir), file_name)
            unless File.file?(entry)
              prompt.say "Skipping directory #{entry}." unless @report
              write_report(entry, '', '', 'Directory - skipped.')
              count[:skipped_dir] += 1
              next
            end
            unless file_name =~ parse_regex
              prompt.say "Skipping file #{file_name}. File name does not match expression." unless @report
              write_report(entry, '', '', 'Mismatch - skipped.')
              count[:unmatched_file] += 1
              next
            end
            target = eval('"' + path_expression + '"')
            target_file = File.basename(target)
            target_dir = File.dirname(target)
            target_dir = File.join(base_dir, target_dir) unless target_dir[0] == '/'
            unless target_dir_list.include?(target_dir)
              prompt.say "-> Create directory '#{target_dir}'" unless @report
              FileUtils.mkpath(target_dir) unless dummy_operation
              target_dir_list << target_dir
            end
            target_path = File.join(target_dir, target_file)
            remark = nil
            action = false
            if File.exist?(target_path)
              if compare_entry(entry, target_path)
                remark = 'Duplicate - skipped.'
                count[:duplicate] += 1
                prompt.error "Duplicate file entry: #{entry}." unless @report
              else
                # puts "source: #{File.mtime(entry)} #{'%11s' % Filesize.new(File.size(entry)).pretty} #{entry}"
                # puts "target: #{File.mtime(target_path)} #{'%11s' % Filesize.new(File.size(target_path)).pretty} #{target_path}"
                if interactive ? prompt.send((overwrite ? :yes : :no), 'Overwrite target?') : overwrite
                  remark = 'Duplicate - updated'
                  action = true
                  count[:update] += 1
                else
                  remark = 'Duplicate - rejected.'
                  prompt.error "ERROR: #{entry} exists with different content." unless @report
                  count[:reject] += 1
                end
              end
            else
              action = true
              count[:move] += 1
            end
            if action
              prompt.say "-> #{file_operation} '#{file_name}' to '#{target}'" unless @report
              case file_operation
              when 'move'
                FileUtils.move(entry, File.join(target_dir, target_file), force: true)
              when 'copy'
                FileUtils.copy(entry, File.join(target_dir, target_file))
              when 'link'
                FileUtils.symlink(entry, File.join(target_dir, target_file), force: true)
              else
                # Shouldn't happen
                raise RuntimeError, "Bad file operation: '#{file_operation}'"
              end unless dummy_operation
            end
            write_report(entry, target_dir, target_file, remark)
          end

          prompt.ok "#{'%8d' % count[:skipped_dir]} dir(s) found and skipped."
          prompt.ok "#{'%8d' % count[:unmatched_file]} file(s) found that did not match and skipped."
          prompt.ok "#{'%8d' % count[:move]} file(s) #{VALID_ACTIONS[file_operation]}."
          prompt.ok "#{'%8d' % count[:duplicate]} duplicate(s) found and skipped."
          prompt.ok "#{'%8d' % count[:update]} changed file(s) found and updated."
          prompt.ok "#{'%8d' % count[:reject]} changed file(s) found and rejected."

          close_report

          prompt.ok 'Done!'

        end


        def open_report
          if (report_file = config.fetch(:report))
            # noinspection RubyStringKeysInHashInspection
            @report_type = {'.csv' => :csv, '.tsv' => :tsv, '.xml' => :xml, '.yml' => :yml}[File.extname(report_file)]
            unless @report_type
              prompt.error "Unknown file type: #{File.extname(report_file)}"
              exit
            end
            @report = File.open(report_file, 'w+')
          end
        end

        def for_tsv(string)
          ; string =~ /\t\n/ ? "\"#{string.gsub('"', '""')}\"" : string;
        end

        def for_csv(string)
          ; string =~ /,\n/ ? "\"#{string.gsub('"', '""')}\"" : string;
        end

        def for_xml(string, type = :attr)
          ; string.encode(xml: type);
        end

        def for_yml(string)
          ; string.inspect.to_yaml;
        end

        def write_report(old_name, new_folder, new_name, remark = nil)
          return unless @report
          case @report_type
          when :tsv
            @report.puts "old_name\tnew_folder\tnew_name\tremark" if @report.size == 0
            @report.puts "#{for_tsv(old_name)}\t#{for_tsv(new_folder)}" +
                             "\t#{for_tsv(new_name)}\t#{for_tsv(remark)}"
          when :csv
            @report.puts 'old_name,new_folder,new_name' if @report.size == 0
            @report.puts "#{for_csv(old_name)},#{for_csv(new_folder)}" +
                             ",#{for_csv(new_name)},#{for_csv(remark)}"
          when :xml
            @report.puts '<?xml version="1.0" encoding="UTF-8"?>' if @report.size == 0
            @report.puts '<report>' if @report.size == 1
            @report.puts '  <file>'
            @report.puts "    <old_name>#{for_xml(old_name, :text)}</old_name>"
            @report.puts "    <new_folder>#{for_xml(new_folder, :text)}</new_folder>"
            @report.puts "    <new_name>#{for_xml(new_name, :text)}</new_name>"
            @report.puts "    <remark>#{for_xml(remark, :text)}</remark>" if remark
            @report.puts '  </file>'
          when :yml
            @report.puts '# Reorganisation report' if @report.size == 0
            @report.puts "- old_name: #{for_yml(old_name)}" +
                             "\n  new_folder: #{for_yml(new_folder)}" +
                             "\n  new_name: #{for_yml(new_name)}" +
                             (remark ? "\n  remark: #{for_yml(remark)}" : '')
          else
            #nothing
          end
        end

        def close_report
          return unless @report
          if @report_type == :xml
            @report.puts '</report>'
          end
          @report.close
        end

        def compare_entry(src, tgt)
          hasher = Libis::Tools::Checksum.new(:SHA256)
          hasher.digest(src) == hasher.digest(tgt)
        end

      end
    end
  end
end