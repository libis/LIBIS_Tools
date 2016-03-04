# coding: utf-8

require 'set'
require 'cgi'

require 'libis/tools/xml_document'
require 'libis/tools/assert'

require_relative 'fix_field'
require_relative 'var_field'
require_relative 'field_format'

module Libis
  module Tools
    module Metadata

      # noinspection RubyTooManyMethodsInspection

      # Base class for reading MARC based records.
      #
      # For indicator selection: '#' or '' (empty) is wildcard; '_' or ' ' (space) is blank.
      class MarcRecord

        # Create a new MarcRecord object
        #
        # @param [XML node] xml_node XML node from Nokogiri or XmlDocument that contains child nodes with the data for
        #         one MARC record.
        def initialize(xml_node)
          @node = xml_node
          @node.document.remove_namespaces!
          @all_records = Hash.new { |h, k| h[k] = Array.new }
        end

        # Access to the XML node that was supplied to the constructor
        # @return [XML node]
        def to_raw
          @node
        end

        # Returns the internal data structure (a Hash) with all the MARC data.
        #
        # The internal structure is a Hash with the tag as key and as value an Array of either FixField or VarField
        # instances.
        #
        # @return [Hash] internal data structure
        def all
          return @all_records unless @all_records.empty?
          @all_records = get_all_records
        end

        # Iterates over all the MARC fields.
        #
        # If a block is supplied it will be called for each field in the MARC record. The supplied argument will be the
        # FixField or VarField instance for each field.
        #
        # @return [Array] The list of the field data or return values for each block call.
        def each
          all.map { |_, field_array| field_array }.flatten.map do |field|
            block_given? ? yield(field) : field
          end
        end

        # Get all fields matching search criteria.
        #
        # A block with one parameter can be supplied when calling this method. Each time a match is found, the block
        # will be called with the field data as argument and the return value of the block will be added to the method's
        # return value. This could for example be used to narrow the selection of the fields:
        #
        #     # Only select 700 tags where $4 subfield contains 'abc', 'def' or 'xyz'
        #     record.all_tags('700') { |v| v.subfield['4'] =~ /^(abc|def|xyz)$/ ? v : nil }.compact
        #
        # @param [String] tag Tag selection string. Tag name with indicators, '#' for wildcard, '_' for blank. If an
        #     extra subfield name is added, a result will be created for each instance found of that subfield.
        # @param [String] subfields Subfield specification. See FieldFormat class for more info; ignored for controlfields.
        # @param [Proc] select_block block that will be executed once for each field found. The block takes one argument
        #     (the field) and should return true or false. True selects the field, false rejects it.
        # @return [Array] If a block was supplied to the method call, the array will contain the result of the block
        #     for each tag found. Otherwise the array will just contain the data for each matching tag.
        def all_tags(tag, subfields = '', select_block = Proc.new { |_| true})
          t, ind1, ind2, subfield = tag =~ /^\d{3}/ ? [tag[0..2], tag[3], tag[4], tag[5]] : [tag, nil, nil, nil]
          result = get_records(t, ind1, ind2, subfield, subfields, &select_block)
          return result unless block_given?
          result.map { |record| yield record }
        end

        alias_method :each_tag, :all_tags

        # Get all fields matching search criteria.
        # As {#all_tags} but without subfield criteria.
        # @param [String] tag Tag selection string. Tag name with indicators, '#' for wildcard, '_' for blank. If an
        #     extra subfield name is added, a result will be created for each instance found of that subfield.
        # @param [Proc] select_block block that will be executed once for each field found. The block takes one argument
        #     (the field) and should return true or false. True selects the field, false rejects it.
        # @return [Array] If a block was supplied to the method call, the array will contain the result of the block
        #     for each tag found. Otherwise the array will just contain the data for each matching tag.
        def select_fields(tag, select_block = nil, &block)
          all_tags(tag, nil, select_block, &block)
        end

        # Find the first tag matching the criteria.
        #
        # If a block is supplied, it will be called with the found field data. The return value will be whatever the
        # block returns. If no block is supplied, the field data will be returned. If nothing was found, the return
        # value is nil.
        #
        # @param [String] tag Tag selection string. Tag name with indicators, '#' for wildcard, '_' for blank.
        # @param [String] subfields Subfield specification. See FieldFormat class for more info; ignored for controlfields.
        # @return [Object] nil if nothing found; field data or whatever block returns.
        def first_tag(tag, subfields = '')
          result = all_tags(tag, subfields).first
          return nil unless result
          return result unless block_given?
          yield result
        end

        # Find all fields matching the criteria.
        # (see #first_tag)
        # @param (see #first_tag)
        def all_fields(tag, subfields)
          r = all_tags(tag, subfields).collect { |t| t.subfields_array(subfields) }.flatten.compact
          return r unless block_given?
          r.map { |field| yield field }
          r.size > 0
        end

        # Find the first field matching the criteria
        # (see #all_fields)
        # @param (see #all_fields)
        def first_field(tag, subfields)
          result = all_fields(tag, subfields).first
          return result unless block_given?
          return false unless result
          yield result
          true
        end

        # Perform action on each field found. Code block required.
        # @param (see #all_fields)
        def each_field(tag, subfields)
          all_fields(tag, subfields).each do |field|
            yield field
          end
        end

        # Dump content to string.
        def marc_dump
          all.values.flatten.each_with_object([]) { |record, m| m << record.dump }.join
        end

        # Save the current MARC record to file.
        # @param [String] filename name of the file
        def save(filename)
          doc = ::Libis::Tools::XmlDocument.new
          doc.root = @node

          return doc unless filename

          doc.save filename, save_with: (::Nokogiri::XML::Node::SaveOptions::NO_EMPTY_TAGS |
                               ::Nokogiri::XML::Node::SaveOptions::AS_XML |
                               ::Nokogiri::XML::Node::SaveOptions::FORMAT
                           )
        end

        # Load XML document from file and create a new {MarcRecord} for it.
        # @param [String] filename name of XML Marc file
        def self.load(filename)
          doc = ::Libis::Tools::XmlDocument.open(filename)
          self.new(doc.root)
        end

        # Load XML document from stream and create a new {MarcRecord} for it.
        # @param [IO,String] io input stream
        def self.read(io)
          io = StringIO.new(io) if io.is_a? String
          doc = ::Libis::Tools::XmlDocument.parse(io)
          self.new(doc.root)
        end

        # Dump Marc record in Aleph Sequential format
        # @return [String] Aleph sequential output
        def to_aseq
          record = ''
          doc_number = tag('001').datas

          all.select { |t| t.is_a? Libis::Tools::Metadata::FixField }.each { |t| record += "#{format('%09s', doc_number)} #{t.tag}   L #{t.datas}\n" }
          all.select { |t| t.is_a? Libis::Tools::Metadata::VarField }.each { |t|
            record += "#{format('%09s', doc_number)} #{t.tag}#{t.ind1}#{t.ind2} L "
            t.keys.each { |k|
              t.subfield_array(k).each { |f|
                record += "$$#{k}#{CGI::unescapeHTML(f)}"
              }
            }
            record += "\n"
          }

          record
        end

        protected

        def element(*parts)
          opts = options parts
          field_format(opts, *parts)
        end

        def list_s(*parts)
          opts = options parts, join: ' '
          field_format(opts, *parts)
        end

        def list_c(*parts)
          opts = options parts, join: ', '
          field_format(opts, *parts)
        end

        def list_d(*parts)
          opts = options parts, join: ' - '
          field_format(opts, *parts)
        end

        def repeat(*parts)
          opts = options parts, join: '; '
          field_format(opts, *parts)
        end

        def opt_r(*parts)
          opts = options parts, fix: '()'
          field_format(opts, *parts)
        end

        def opt_s(*parts)
          opts = options parts, fix: '[]'
          field_format(opts, *parts)
        end

        def odis_link(group, id, label)
          "http://www.odis.be/lnk/#{group.downcase[0, 2]}_#{id}\##{label}"
        end

        private

        def options(args, default = {})
          default.merge(args.last.is_a?(::Hash) ? args.pop : {})
        end

        def field_format(default_options, *parts)
          Libis::Tools::Metadata::FieldFormat.new(*parts).add_default_options(default_options).to_s
        end

        def get_records(tag, ind1 = '', ind2 = '', subfield = nil, subfields = '', &block)

          ind1 ||= ''
          ind2 ||= ''
          subfields ||= ''

          ind1.tr!('_', ' ')
          ind1.tr!('#', '')

          ind2.tr!('_', ' ')
          ind2.tr!('#', '')

          found = all[tag].select do |v|
            result = v.is_a?(Libis::Tools::Metadata::FixField) ||
                ((ind1.empty? or v.ind1 == ind1) &&
                    (ind2.empty? or v.ind2 == ind2) &&
                    v.match(subfields)
                )
            result &&= block.call(v) if block
            result
          end

          return found unless subfield

          # duplicate tags for subfield instances
          found.map do |field|
            next unless field.is_a? Libis::Tools::Metadata::FixField
            field.subfield_data[subfield].map do |sfield|
              field.dup.subfield_data[subfield] = [sfield]
            end
          end.compact.flatten

        end

      end
    end
  end
end
