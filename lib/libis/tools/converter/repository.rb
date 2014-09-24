# coding: utf-8

require 'set'
require 'singleton'

require 'LIBIS/tools/logger'

require_relative 'chain'

module LIBIS
  module Tools
    module Converter

      class Repository
        include Singleton
        include Logger

        attr_reader :converters
        attr_writer :converters_glob

        def initialize
          @converters = Set.new
          @converters_glob = File.join(File.basename(__FILE__), '*_converter.rb')
        end

        def Repository.register(converter_class)
          instance.converters.add? converter_class
        end

        def Repository.get_converters
          if instance.converters.empty?
            Dir.glob(instance.converters_glob).each do |filename|
              # noinspection RubyResolve
              require File.expand_path(filename)
            end
          end
          instance.converters
        end

        def Repository.get_converter_chain(src_type, tgt_type, operations = [])
          msg = "conversion from #{src_type.to_s} to #{tgt_type.to_s}"
          chain_list = recursive_chain src_type, tgt_type, operations
          if chain_list.length > 1
            warn "Found more than one conversion chain for #{msg}. Picking the first one."
          end
          if chain_list.empty?
            error "No conversion chain found for #{msg}"
            return nil
          end
          chain_list.each do |chain|
            msg = "Base chain: #{src_type.to_s}"
            chain.each do |node|
              msg += "->#{node[:converter].name}:#{node[:target].to_s}"
            end
            debug msg
          end
          ::LIBIS::Tools::Converters::Chain.new(chain_list[0])
        end

        private

        def Repository.recursive_chain(src_type, tgt_type, operations, chains_found = [], current_chain = [])
          return chains_found unless current_chain.length < 8 # upper limit of converter chain we want to consider

          get_converters.each do |converter|
            if converter.conversion? src_type, tgt_type and !current_chain.any? { |c|
              c[:converter] == converter and c[:target] == tgt_type }
              node = Hash.new
              node[:converter] = converter
              node[:target] = tgt_type
              sequence = current_chain.dup
              sequence << node
              # check if the chain supports all the operations
              success = true
              operations.each do |op, _|
                success = false unless sequence.any? do |n|
                  n[:converter].new.respond_to? op.to_s.downcase.to_sym
                end
              end
              if success
                # we only want to remember the shortest converter chains
                if !chains_found.empty? and sequence.length < chains_found[0].length
                  chains_found.clear
                end
                chains_found << sequence if chains_found.empty? or sequence.length == chains_found[0].length
              end
            end
          end

          return chains_found unless chains_found.empty? or current_chain.length + 1 < chains_found[0].length

          get_converters.each do |converter|
            next unless converter.input_type? src_type
            converter.output_types(src_type).each do |tmp_type|
              # would like to enable the following for optimalizationn, but some operation may require such a step
              # next if tmp_type == src_type
              # next if current_chain.any? { |c| c[:target] == tmp_type}
              recursive_chain(tmp_type, tgt_type, operations, chains_found,
                              current_chain.dup << {:converter => converter, :target => tmp_type})
            end
          end

          chains_found
        end

      end

    end
  end
end
