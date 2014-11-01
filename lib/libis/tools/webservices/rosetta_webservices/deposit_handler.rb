# encoding: utf-8

require 'libis/tools/webservices/rosetta_webservices/client'
require 'libis/tools/extend/hash'

module LIBIS
  module Tools
    module Webservices
      module RosettaServices

        class DepositHandler < ::LIBIS::Tools::Webservices::RosettaServices::Client

          def initialize(base_url = 'http://depot.lias.be')
            super 'deposit', 'DepositWebServices', base_url
          end

          # @param [Object] flow_id ID of the material flow used
          # @param [Object] subdir name of the load directory
          # @param [Object] producer_id ID of the Producer
          # @param [Object] deposit_set_id ID of the set of deposits
          def submit(flow_id, subdir, producer_id, deposit_set_id = '1')
            request :submit_deposit_activity, {
                arg0: @pds_handle,
                arg1: flow_id,
                arg2: subdir,
                arg3: producer_id,
                arg4: deposit_set_id
            }.cleanup
          end

          # @param [String] date_from Start date for lookup range
          # @param [String] date_to End date for lookup range
          # @param [Hash] options optional string parameters limiting the search with:
          # - status: Status of the deposit [All (default), In process, Rejected, Draft, Approved, Declined]
          # - producer_id: optional, limits by producer_id
          # - agent_id: optional, limits by agent_id
          # - start_record: optional, pagination start
          # - end_record: optional, pagination end
          def get_by_submit_date(date_from, date_to, options = {})
            options = {
                status: 'All',
                producer_id: nil,
                agent_id: nil,
                start_record: nil,
                end_record: nil
            }.merge options
            params = {
                arg0: @pds_handle,
                arg1: options[:status],
                arg2: options[:producer_id],
                arg3: options[:agent_id],
                arg4: date_from,
                arg5: date_to,
                arg6: options[:start_record],
                arg7: options[:end_record]
            }.cleanup
            method = :get_deposit_activity_by_submit_date
            parse_deposit_info(block_given? ? request(method, params, &block) : request(method, params))
          end

          # @param [String] date_from Start date for lookup range
          # @param [String] date_to End date for lookup range
          # @param [Object] flow_id ID of the material flow used
          # @param [Hash] options optional string parameters limiting the search with:
          # - status: Status of the deposit [All (default), In process, Rejected, Draft, Approved, Declined]
          # - producer_id: optional, limits by producer_id
          # - agent_id: optional, limits by agent_id
          # - start_record: optional, pagination start
          # - end_record: optional, pagination end
          def get_by_submit_flow(date_from, date_to, flow_id, options = {})
            options = {
                status: 'All',
                producer_id: nil,
                agent_id: nil,
                start_record: nil,
                end_record: nil
            }.merge options
            params = {
                arg0: @pds_handle,
                arg1: options[:status],
                arg2: flow_id,
                arg3: options[:producer_id],
                arg4: options[:agent_id],
                arg5: date_from,
                arg6: date_to,
                arg7: options[:start_record],
                arg8: options[:end_record]
            }.cleanup
            method = :get_deposit_activity_by_submit_date_by_material_flow
            parse_deposit_info(block_given? ? request(method, params, &block) : request(method, params))
          end

          # @param [String] date_from Start date for lookup range
          # @param [String] date_to End date for lookup range
          # @param [Hash] options optional string parameters limiting the search with:
          # - status: Status of the deposit [All (default), In process, Rejected, Draft, Approved, Declined]
          # - producer_id: optional, limits by producer_id
          # - agent_id: optional, limits by agent_id
          # - start_record: optional, pagination start
          # - end_record: optional, pagination end
          def get_by_update_date(date_from, date_to, options = {})
            options = {
                status: 'All',
                producer_id: nil,
                agent_id: nil,
                start_record: nil,
                end_record: nil
            }.merge options
            params = {
                arg0: @pds_handle,
                arg1: options[:status],
                arg2: options[:producer_id],
                arg3: options[:agent_id],
                arg4: date_from,
                arg5: date_to,
                arg6: options[:start_record],
                arg7: options[:end_record]
            }.cleanup
            method = :get_deposit_activity_by_update_date
            parse_deposit_info(block_given? ? request(method, params, &block) : request(method, params))
          end

          # @param [String] date_from Start date for lookup range
          # @param [String] date_to End date for lookup range
          # @param [Object] flow_id ID of the material flow used
          # @param [Hash] options optional string parameters limiting the search with:
          # - status: Status of the deposit [All (default), In process, Rejected, Draft, Approved, Declined]
          # - producer_id: optional, limits by producer_id
          # - agent_id: optional, limits by agent_id
          # - start_record: optional, pagination start
          # - end_record: optional, pagination end
          def get_by_update_flow(date_from, date_to, flow_id, options = {})
            options = {
                status: 'All',
                producer_id: nil,
                agent_id: nil,
                start_record: nil,
                end_record: nil
            }.merge options
            params = {
                arg0: @pds_handle,
                arg1: options[:status],
                arg2: flow_id,
                arg3: options[:producer_id],
                arg4: options[:agent_id],
                arg5: date_from,
                arg6: date_to,
                arg7: options[:start_record],
                arg8: options[:end_record]
            }.cleanup
            method = :get_deposit_activity_by_update_date_by_material_flow
            parse_deposit_info(block_given? ? request(method, params, &block) : request(method, params))
          end

          protected

          def result_parser(response)
            LIBIS::Tools::XmlDocument.parse(super(response)).to_hash
          end

          def parse_deposit_info(response)
            list = response['deposit_activity_list']['records']['record'] rescue []
            list = [list] unless list.is_a? Array
            list.map do |record|
              {
                  title: record['title'],
                  sip: record['sip_id'],
                  deposit: record['deposit_activity_id'],
                  status: record['status'],
                  reason: record['sip_reason'],
                  date: [record['creation_date'], record['submit_date'], record['update_date']],
              }.cleanup
            end
          end


        end

      end
    end
  end
end