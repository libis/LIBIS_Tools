require_relative 'rosetta_webservices/pds_handler'
require_relative 'rosetta_webservices/producer_handler'
require_relative 'rosetta_webservices/deposit_handler'
require_relative 'rosetta_webservices/sip_handler'
require_relative 'rosetta_webservices/ie_handler'

require 'libis/tools/mets_file'

require 'csv'
require 'write_xlsx'
require 'backports'
require 'awesome_print'

module LIBIS
  module Tools
    module Webservices

      class Rosetta

        attr_reader :pds_service, :producer_service, :deposit_service, :sip_service, :ie_service

        # @param [String] base_url
        def initialize(base_url = 'http://depot.lias.be')
          @pds_service = LIBIS::Tools::Webservices::RosettaServices::PdsHandler.new
          @producer_service = LIBIS::Tools::Webservices::RosettaServices::ProducerHandler.new base_url
          @deposit_service = LIBIS::Tools::Webservices::RosettaServices::DepositHandler.new base_url
          @sip_service = LIBIS::Tools::Webservices::RosettaServices::SipHandler.new base_url
          @ie_service = LIBIS::Tools::Webservices::RosettaServices::IeHandler.new base_url
        end

        # @param [String] name
        # @param [String] passwd
        # @param [String] institute
        # @return [String] PDS handle
        def login(name, passwd, institute)
          handle = @pds_service.login(name, passwd, institute)
          @producer_service.pds_handle = handle
          @deposit_service.pds_handle = handle
          @sip_service.pds_handle = handle
          @ie_service.pds_handle = handle
          handle
        end

        # Searches for all deposits in the date range and for the given flow id. The method returns a list of all
        # deposits, including information about the sip, the related IEs and a breakdown of the IE's METS file.
        #
        # @param [String] from_date
        # @param [String] to_date
        # @param [String] flow_id
        # @param [String] options
        # @return [Hash] detailed deposit information
        def get_deposits(from_date, to_date, flow_id, options = {})
          deposits = @deposit_service.get_by_submit_flow(from_date, to_date, flow_id, {status: 'Approved'}.merge(options))
          deposits.each do |deposit|
            ies = @sip_service.get_ies(deposit[:sip])
            ies_info = ies.map do |ie|
              title = nil
              dir = nil
              begin
                md = @ie_service.get_metadata(ie).to_hash
                dc = md['mets:mets']['mets:dmdSec']['mets:mdWrap']['mets:xmlData']['dc:record']
                title = dc['dc:title'].to_s
                dir = dc['dc:identifier'].split('\\').last.to_s
              rescue
                # ignore
              end
              # retrieve ie mets file
              xml_doc = @ie_service.get_mets(ie)
              ie_info = LIBIS::Tools::MetsFile.parse(xml_doc.to_xml)
              {
                  ie: ie,
                  title: title,
                  dir: dir,
                  content: ie_info
              }.cleanup
            end
            deposit[:ies] = ies_info
          end
          deposits
        end

        # @param [String] report_file
        # @param [Array] deposits
        def get_deposit_report(report_file, deposits)
          # create and open Workbook
          workbook = WriteXLSX.new(report_file)

          # set up some formatting
          ie_data_header_format = workbook.add_format(bold: 1)
          rep_name_format = workbook.add_format(bold: 1)
          file_header_format = workbook.add_format(bold: 1)

          # First Sheet is an overview of all dossiers
          overview = workbook.add_worksheet('overzicht dossiers')
          ie_data_keys = Set.new %w[folder dossier link]
          ie_list = [] # ie info will be collected in this array to be printed later

          # iterate over all deposits
          deposits.each do |deposit|
            # iterate over all IEs
            deposit[:ies].sort {|x,y| x[0] <=> y[0]}.each do |ie|
              @ie = ie
              # noinspection RubyStringKeysInHashInspection
              ie_data = {
                  'folder' => "#{ie[:dir]}",
                  'dossier' => ie[:title],
                  'link' => "http://depot.lias.be/delivery/DeliveryManagerServlet?dps_pid=#{ie[:ie]}"
              }
              [
                  ie[:content][:dmd],
                  ie[:content][:amd][:tech]['generalIECharacteristics'],
                  ie[:content][:amd][:rights]
              ].each do |data|
                ie_data.merge data
              end
              dossier_sheet = workbook.add_worksheet(ie[:dir])
              dossier_row = 0

              ie[:content].each do |rep_name, rep|
                next unless rep_name.is_a?(String)
                @rep = rep
                file_data_keys = Set.new %w(folder naam link mimetype puid formaat versie)
                file_list = []

                dossier_sheet.write_row(dossier_row, 0, [rep_name], rep_name_format)
                %w(preservationType usageType).each do |key|
                  dossier_row += 1
                  dossier_sheet.write_row(
                      dossier_row, 0,
                      [
                          key.underscore.gsub('_',' '),
                          rep[:amd][:tech]['generalRepCharacteristics'][key]
                      ]
                  )
                end
                dossier_row += 2

                file_proc = lambda do |file|
                  @file = file
                  if file[:id]
                    tech = file[:amd][:tech]
                    # noinspection RubyStringKeysInHashInspection
                    file_data = {
                        'folder' => (tech['generalFileCharacteristics']['fileOriginalPath'] rescue '').split('/')[1..-1].join('\\'),
                        'naam' => (tech['generalFileCharacteristics']['fileOriginalName'] rescue nil),
                        'link' => ("http://depot.lias.be/delivery/DeliveryManagerServlet?dps_pid=#{file[:id]}" rescue nil),
                        'mimetype' => (tech['fileFormat']['mimeType'] rescue nil),
                        'puid' => (tech['fileFormat']['formatRegistryId'] rescue nil),
                        'formaat' => (tech['fileFormat']['formatDescription'] rescue nil),
                        'versie' => (tech['fileFormat']['formatVersion'] rescue nil),
                        'viruscheck' => (tech['fileVirusCheck']['status'] rescue nil),
                        'file_type' => (tech['generalFileCharacteristics']['FileEntityType']),
                        'groep' => file[:group],
                    }
                    data = tech['fileValidation']
                    if data
                      valid = (data['isValid'] == 'true') rescue nil
                      well_formed = (data['isWellFormed'] == 'true') rescue nil
                      file_data['validatie'] = if valid && well_formed
                                                 'OK'
                                               else
                                                 'niet OK'
                                               end
                    end
                    data = tech['significantProperties']
                    if data
                      file_data[data['significantPropertiesType']] = data['significantPropertiesValue']
                    end
                    data = file[:dmd]
                    if data
                      data.each { |key, value| file_data[key] = value }
                    end
                    file_list << file_data
                    file_data_keys.merge file_data.keys
                  else
                    file.each do |_, value|
                      next unless value.is_a? Hash
                      # noinspection RubyScope
                      file_proc.call(value)
                    end
                  end
                end

                rep.keys.each do |key|
                  file_proc.call(rep[key]) if key.is_a?(String)
                end

                table_start = dossier_row
                dossier_sheet.write_row(dossier_row, 0, file_data_keys.to_a, file_header_format)
                file_list.each do |file_info|
                  dossier_row += 1
                  file_data = []
                  file_data_keys.each {|key| file_data << file_info[key]}
                  dossier_sheet.write_row(dossier_row, 0, file_data)
                end
                table_end = dossier_row

                dossier_sheet.add_table(
                    table_start, 0, table_end, file_data_keys.size - 1,
                    style: 'Table Style Medium 16', name: rep[:id],
                    columns: file_data_keys.map {|key| { header: key }}
                )

                dossier_row += 2
              end
              ie_data_keys.merge ie_data.keys
              ie_list << ie_data
            end
          end

          # write ie data to overview worksheet
          overview.write_row(0,0,ie_data_keys.to_a, ie_data_header_format)
          overview_row = 1
          ie_list.each do |ie_info|
            ie_data = []
            ie_data_keys.each { |key| ie_data << ie_info[key] }
            overview.write_row(overview_row, 0, ie_data)
            overview_row += 1
          end

          # close and save workbook
          workbook.close
        end

        def file
          @file
        end

        def ie
          @ie
        end

        def rep
          @rep
        end

      end

    end
  end
end
