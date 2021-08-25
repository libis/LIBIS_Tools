# encoding: utf-8
require 'ostruct'

require 'libis/tools/extend/hash'
require_relative 'xml_document'
require_relative 'thread_safe'
require_relative 'mets_dnx'
require_relative 'mets_objects'

module Libis
  module Tools

    # noinspection RubyResolve

    # This class supports creating METS files in a friendlier way than by creating an XML file.
    #
    # There are sub-classes that represent {::Libis::Tools::MetsFile::Representation}s,
    # {::Libis::Tools::MetsFile::File}s, {::Libis::Tools::MetsFile::Div}isions and {::Libis::Tools::MetsFile::Map}s.
    # These are simple container classes that take care of assigning proper ids and accept most known attributes.
    # Each of the container classes have a corresponding method on the METS class that takes a Hash with attributes
    # and returns the created object.
    #
    # {::Libis::Tools::MetsFile::Div} and {::Libis::Tools::MetsFile::File} instances can be added to a
    # {::Libis::Tools::MetsFile::Div} instance and a Div can be associated with a
    # {::Libis::Tools::MetsFile::Representation}, thus creating a structmap.
    #
    # The {#amd_info=} method on the {MetsFile} class sets the main amd parameters and
    #
    # With the help of the {DnxSection} class and it's derived classes, the container classes can generate the amd
    # sections for the METS file.
    class MetsFile
      include ::Libis::Tools::ThreadSafe

      # Keeps track of {::Libis::Tools::MetsFile::Representation}s created
      attr_reader :representations
      # Keeps track of {::Libis::Tools::MetsFile::File}s created
      attr_reader :files
      # Keeps track of {::Libis::Tools::MetsFile::Div}s created
      attr_reader :divs
      # Keeps track of {::Libis::Tools::MetsFile::Map}s created
      attr_reader :maps

      # noinspection RubyConstantNamingConvention

      # Namespace constants for METS XML
      NS = {
          mets: 'http://www.loc.gov/METS/',
          dc: 'http://purl.org/dc/elements/1.1/',
          dnx: 'http://www.exlibrisgroup.com/dps/dnx',
          xlin: 'http://www.w3.org/1999/xlink',
      }

      # Creates an initializes a new {MetsFile} instance
      def initialize
        @representations = {}
        @files = {}
        @divs = {}
        @maps = {}
        @dnx = {}
        @dc_record = nil
        @id_map = {}
      end

      # Reads an existing METS XML file and parses into a large Hash structure for inspection.
      #
      # It will not immediately allow you to create a {MetsFile} instance from it, but with some inspection and
      # knowledge of METS file structure it should be possible to recreate a similar file using the result.
      #
      # The returned Hash has the following structure:
      #
      # * :amd - the general AMD section with subsections
      # * :dmd - the general DMD section with the DC record(s)
      # Each amd section has one or more subsections with keys :tech, :rights, :source or :digiprov. Each
      # subsection is a Hash with section id as key and an array as value. For each <record> element a Hash is
      # added to the array with <key@id> as key and <key> content as value.
      #
      # @param [String,Hash,::Libis::Tools::XmlDocument, Nokogiri::XML::Document] xml XML file in any of the listed formats.
      # @return [Hash] The parsed information.
      def self.parse(xml)
        xml_doc = case xml
                    when String
                      Libis::Tools::XmlDocument.parse(xml).document
                    when Hash
                      Libis::Tools::XmlDocument.from_hash(xml).document
                    when Libis::Tools::XmlDocument
                      xml.document
                    when Nokogiri::XML::Document
                      xml
                    else
                      raise ArgumentError, "Libis::Tools::MetsFile#parse does not accept input of type #{xml.class}"
                  end

        dmd_sec = xml_doc.root.xpath('mets:dmdSec', NS).inject({}) do |hash_dmd, dmd|
          hash_dmd[dmd[:ID]] = dmd.xpath('.//dc:record', NS).first.children.inject({}) do |h, c|
            h[c.name] = c.content if c.name != 'text'
            h
          end
          hash_dmd
        end
        amd_sec = xml_doc.root.xpath('mets:amdSec', NS).inject({}) do |hash_amd, amd|
          hash_amd[amd[:ID]] = [:tech, :rights, :source, :digiprov].inject({}) do |hash_sec, sec|
            md = amd.xpath("mets:#{sec}MD", NS).first
            return hash_sec unless md
            # hash_sec[sec] = md.xpath('mets:mdWrap/dnx:dnx/dnx:section', NS).inject({}) do |hash_md, dnx_sec|
            hash_sec[sec] = md.xpath('.//dnx:section', NS).inject({}) do |hash_md, dnx_sec|
              hash_md[dnx_sec[:id]] = dnx_sec.xpath('dnx:record', NS).inject([]) do |records, dnx_record|
                records << dnx_record.xpath('dnx:key', NS).inject({}) do |record_hash, key|
                  record_hash[key[:id]] = key.content
                  record_hash
                end
                records
              end
              hash_md
            end
            hash_sec
          end
          hash_amd
        end
        rep_sec = xml_doc.root.xpath('.//mets:fileGrp', NS).inject({}) do |hash_rep, rep|
          hash_rep[rep[:ID]] = {
              amd: amd_sec[rep[:ADMID]],
              dmd: amd_sec[rep[:DMDID]]
          }.cleanup.merge(
              rep.xpath('mets:file', NS).inject({}) do |hash_file, file|
                hash_file[file[:ID]] = {
                    group: file[:GROUPID],
                    amd: amd_sec[file[:ADMID]],
                    dmd: dmd_sec[file[:DMDID]],
                }.cleanup
                hash_file
              end
          )
          hash_rep
        end
        {amd: amd_sec['ie-amd'],
         dmd: dmd_sec['ie-dmd'],
        }.cleanup.merge(
            xml_doc.root.xpath('.//mets:structMap[@TYPE="PHYSICAL"]', NS).inject({}) do |hash_map, map|
              rep_id = map[:ID].gsub(/-\d+$/, '')
              rep = rep_sec[rep_id]
              div_parser = lambda do |div|
                if div[:TYPE] == 'FILE'
                  file_id = div.xpath('mets:fptr').first[:FILEID]
                  {
                      id: file_id
                  }.merge rep[file_id]
                else
                  div.children.inject({}) do |hash, child|
                    # noinspection RubyScope
                    hash[child[:LABEL]] = div_parser.call(child)
                    hash
                  end
                end
              end
              hash_map[map.xpath('mets:div').first[:LABEL]] = {
                  id: rep_id,
                  amd: rep_sec[rep_id][:amd],
                  dmd: rep_sec[rep_id][:dmd],
              }.cleanup.merge(
                  map.xpath('mets:div', NS).inject({}) do |hash, div|
                    hash[div[:LABEL]] = div_parser.call(div)
                  end
              )
              hash_map
            end
        )
      end

      # Sets the DC record for the global amd section.
      #
      # @param [String] xml Serialized Dublin Core XML file
      def dc_record=(xml)
        @dc_record = xml
      end

      # Sets the attributes for the global amd section.
      #
      # @param [Hash] hash name, value pairs for the DNX sections. Each will go into it's appropriate AMD and DNX
      # sections automatically.
      #       The following names are currently supported:
      #       * status
      #       * entity_type
      #       * user_a
      #       * user_b
      #       * user_c
      #       * submission_reason
      #       * retention_id - RentionPolicy ID
      #       * harvest_url
      #       * harvest_id
      #       * harvest_target
      #       * harvest_group
      #       * harvest_date
      #       * harvest_time
      #       * collection_id - Collection ID where the IE should be added to
      #       * access_right - AccessRight ID
      #       * source_metadata - Array with hashes like {type: 'MyXML', data: '<xml ....>'}
      def amd_info=(hash)
        tech_data = []
        data = {
            groupID: hash[:group_id]
        }.cleanup
        tech_data << ObjectCharacteristics.new(data) unless data.empty?
        data = {
            status: hash[:status],
            IEEntityType: hash[:entity_type],
            UserDefinedA: hash[:user_a],
            UserDefinedB: hash[:user_b],
            UserDefinedC: hash[:user_c],
            submissionReason: hash[:submission_reason],
        }.cleanup
        tech_data << GeneralIECharacteristics.new(data) unless data.empty?
        data = {
            policyId: hash[:retention_id],
        }.cleanup
        tech_data << RetentionPolicy.new(data) unless data.empty?
        data = {
            primarySeedURL: hash[:harvest_url],
            WCTIdentifier: hash[:harvest_id],
            targetName: hash[:harvest_target],
            group: hash[:harvest_group],
            harvestDate: hash[:harvest_date],
            harvestTime: hash[:harvest_time],
        }.cleanup
        tech_data << WebHarvesting.new(data) unless data.empty?
        data = {
            collectionId: hash[:collection_id]
        }.cleanup
        tech_data << Collection.new(data) unless data.empty?
        @dnx[:tech] = tech_data unless tech_data.empty?
        data = {
            policyId: hash[:access_right]
        }.cleanup
        rights_data = []
        rights_data << AccessRightsPolicy.new(data) unless data.empty?
        @dnx[:rights] = rights_data unless rights_data.empty?
        (hash[:source_metadata] || []).each_with_index do |metadata, i|
          @dnx["source-#{metadata[:type].to_s.upcase}-#{i+1}"] = metadata[:data]
        end
      end

      def get_id(klass)
        self.mutex.synchronize do
          @id_map[klass] = (@id_map[klass] ? @id_map[klass] + 1 : 1)
          return @id_map[klass]
        end
      end

      # Create a new representation. See {::Libis::Tools::MetsFile::Representation} for supported Hash keys.
      # @param [Hash] hash
      # @return [Libis::Tools::MetsFile::Representation]
      def representation(hash = {})
        rep = ::Libis::Tools::MetsFile::Representation.new
        rep.set_id get_id(::Libis::Tools::MetsFile::Representation)
        rep.set_from_hash hash
        @representations[rep.id] = rep
      end

      # Create a new division. See {Div} for supported Hash keys.
      # @param [Hash] hash
      # @return [Libis::Tools::MetsFile::Div]
      def div(hash = {})
        div = Libis::Tools::MetsFile::Div.new
        div.set_id get_id(::Libis::Tools::MetsFile::Div)
        div.set_from_hash hash
        @divs[div.id] = div
      end

      # Create a new file. See {File} for supported Hash keys.
      # @param [Hash] hash
      # @return [Libis::Tools::MetsFile::File]
      def file(hash = {})
        file = Libis::Tools::MetsFile::File.new
        file.set_id get_id(::Libis::Tools::MetsFile::File)
        file.set_from_hash hash
        @files[file.id] = file
      end

      # Create a new structmap.
      # @param [Libis::Tools::MetsFile::Representation] rep
      # @param [Libis::Tools::MetsFile::Div] div
      # @param [Boolean] logical if true, create a logical structmap; if false (default): a physical structmap.
      # @return [Libis::Tools::MetsFile::Map]
      def map(rep, div, logical = false)
        map = Libis::Tools::MetsFile::Map.new
        map.set_id get_id(::Libis::Tools::MetsFile::Map)
        map.representation = rep
        map.div = div
        map.is_logical = logical
        @maps[map.id] = map
      end

      # Create the METS XML document.
      # @return [Libis::Tools::XmlDocument]
      def xml_doc
        ::Libis::Tools::XmlDocument.build do |xml|
          xml[:mets].mets(
              'xmlns:mets' => NS[:mets],
          ) {
            add_dmd(xml)
            add_amd(xml)
            add_filesec(xml)
            add_struct_map(xml)
          }
        end
      end

      protected

      # ID for the DMD section of a representation, division or file
      def dmd_id(id)
        "#{id}-dmd"
      end

      # ID for the AMD section of a representation, division or file
      def amd_id(id)
        "#{id}-amd"
      end

      # Helper method to create the XML DMD sections
      def add_dmd(xml, object = nil)
        case object
          when NilClass
            add_dmd_section(xml, 'ie', @dc_record)
            # @representations.values.each { |rep| add_dmd(xml, rep) }
            @files.values.each { |file| add_dmd(xml, file) }
          when Libis::Tools::MetsFile::File
            add_dmd_section(xml, object.xml_id, object.dc_record)
          # when Representation
          #   add_dmd_section(xml, object.xml_id, object.dc_record)
          else
            raise RuntimeError, "Unsupported object type: #{object.class}"
        end
      end

      # Helper method to create the XML AMD sections
      def add_amd(xml, object = nil)
        case object
          when NilClass
            raise RuntimeError, 'No IE amd info present.' unless @dnx
            add_amd_section(xml, 'ie', @dnx)
            @representations.values.each { |rep| add_amd(xml, rep) }
            @files.values.each { |file| add_amd(xml, file) }
          when Libis::Tools::MetsFile::File
            add_amd_section(xml, object.xml_id, object.amd)
          when Libis::Tools::MetsFile::Representation
            add_amd_section(xml, object.xml_id, object.amd)
          else
            raise RuntimeError, "Unsupported object type: #{object.class}"
        end
      end

      # Helper method to create the XML file section
      def add_filesec(xml, object = nil, representation = nil)
        case object
          when NilClass
            xml[:mets].fileSec {
              @representations.values.each { |rep| add_filesec(xml, rep) }
            }
          when Libis::Tools::MetsFile::Representation
            h = {
                ID: object.xml_id,
                USE: object.usage_type,
                ADMID: amd_id(object.xml_id),
                # DDMID: dmd_id(object.xml_id),
            }.cleanup
            xml[:mets].fileGrp(h) {
              @files.values.each { |obj| add_filesec(xml, obj, object) }
            }
          when Libis::Tools::MetsFile::File
            if object.representation == representation
              h = {
                  ID: object.xml_id,
                  MIMETYPE: object.mimetype,
                  ADMID: amd_id(object.xml_id),
                  GROUPID: object.make_group_id,
              }.cleanup
              h[:DMDID] = dmd_id(object.xml_id) if object.dc_record

              xml[:mets].file(h) {
                # noinspection RubyStringKeysInHashInspection
                xml[:mets].FLocat(
                    LOCTYPE: 'URL',
                    'xmlns:xlin' => NS[:xlin],
                    'xlin:href' => object.target_location,
                )
              }
            end
          else
            raise RuntimeError, "Unsupported object type: #{object.class}"
        end
      end

      # Helper method to create the Structmap
      def add_struct_map(xml, object = nil)
        case object
          when NilClass
            @maps.values.each do |map|
              xml[:mets].structMap(
                  ID: "#{map.representation.xml_id}-1",
                  TYPE: (map.is_logical ? 'LOGICAL' : 'PHYSICAL'),
              ) {
                xml[:mets].div(LABEL: map.representation.label) {
                  add_struct_map(xml, map.div) if map.div
                }
              }
            end
          when Libis::Tools::MetsFile::Div
            h = {
                LABEL: object.label,
            }.cleanup
            xml[:mets].div(h) {
              object.files.each { |file| add_struct_map(xml, file) }
              object.divs.each { |div| add_struct_map(xml, div) }
            }
          when Libis::Tools::MetsFile::File
            h = {
                LABEL: object.label,
                TYPE: 'FILE',
            }.cleanup
            xml[:mets].div(h) {
              xml[:mets].fptr(FILEID: object.xml_id)
            }
          else
            raise RuntimeError, "Unsupported object type: #{object.class}"
        end

      end

      # Helper method to create a single XML DMD section
      def add_dmd_section(xml, id, dc_record = nil)
        return if dc_record.nil?
        xml[:mets].dmdSec(ID: dmd_id(id)) {
          xml[:mets].mdWrap(MDTYPE: 'DC') {
            xml[:mets].xmlData {
              xml[:dc] << dc_record
            }
          }
        }
      end

      # Helper method to create a single AMD section
      def add_amd_section(xml, id, dnx_sections = {})
        xml[:mets].amdSec(ID: amd_id(id)) {
          dnx_sections.each do |section_type, data|
            if section_type.to_s =~ /^source-(.*)-\d+$/
              xml[:mets].send('sourceMD', ID: "#{amd_id(id)}-#{section_type.to_s}") {
                xml[:mets].mdWrap(MDTYPE: $1) {
                  xml[:mets].xmlData {
                    xml << data
                  }
                }
              }
            else
              xml[:mets].send("#{section_type}MD", ID: "#{amd_id(id)}-#{section_type.to_s}") {
                xml[:mets].mdWrap(MDTYPE: 'OTHER', OTHERMDTYPE: 'dnx') {
                  xml[:mets].xmlData {
                    add_dnx_sections(xml, data)
                  }
                }
              }
            end
          end
        }
      end

      # Helper method to create the XML DNX sections
      def add_dnx_sections(xml, section_data)
        section_data ||= []
        xml.dnx(xmlns: NS[:dnx]) {
          (section_data).each do |section|
            xml.section(id: section.tag) {
              records = section[:array] || [section]
              records.each do |data|
                xml.record {
                  data.each_pair do |key, value|
                    next if value.nil?
                    xml.key(value, id: key)
                  end
                }
              end
            }
          end
        }
      end

      # Helper method to parse a XML div
      def parse_div(div, rep)
        if div[:TYPE] == 'FILE'
          file_id = div.children.first[:FILEID]
          {
              id: file_id
          }.merge rep[file_id]
        else
          div.children.inject({}) do |hash, child|
            hash[child[:LABEL]] = parse_div child, rep
            hash
          end
        end
      end

    end

  end
end
