# encoding: utf-8
require_relative 'spec_helper'
require 'rspec/matchers'
require 'libis/tools/spreadsheet'

describe 'Libis::Tools::Spreadsheet' do

  let(:path) {File.absolute_path('data', File.dirname(__FILE__))}
  let(:options) { {} }
  let(:ss) {
    Libis::Tools::Spreadsheet.new(
        File.join(path, file_name),
        { required: required_headers,
        optional: optional_headers
        }.merge(options)
    )
  }

  let(:optional_headers) {[]}

  context 'CSV file' do
    context 'with headers' do
      let(:file_name) {'test-headers.csv'}

      context 'well-formed' do

        let(:required_headers) {%w'FirstName LastName'}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains expected headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq %w'FirstName LastName address'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['FirstName']).to eq 'John'
          expect(row['LastName']).to eq 'Smith'
          expect(row['address']).to eq 'mystreet 1, myplace'
          expect(row['phone']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 1
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['FirstName']).to eq 'John'
          expect(row['LastName']).to eq 'Smith'
          expect(row['address']).to eq 'mystreet 1, myplace'
          expect(row['phone']).to be_nil
        end

      end

      context 'not specified' do

        let(:required_headers) {[]}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains expected headers' do
          expect(ss.headers).to eq %w'FirstName LastName address'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['FirstName']).to eq 'John'
          expect(row['LastName']).to eq 'Smith'
          expect(row['address']).to eq 'mystreet 1, myplace'
          expect(row['phone']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 1
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['FirstName']).to eq 'John'
          expect(row['LastName']).to eq 'Smith'
          expect(row['address']).to eq 'mystreet 1, myplace'
          expect(row['phone']).to be_nil
        end

      end

      context 'not well-formed' do

        let(:required_headers) {%w'FirstName LastName address phone'}

        it 'throws error when opened' do
          expect {ss}.to raise_error(RuntimeError, 'Headers not found: ["phone"].')
        end
      end

    end

    context 'without headers' do
      let(:file_name) {'test-noheaders.csv'}

      context 'well-formed and strict' do
        let(:required_headers) {%w'FirstName LastName'}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains only required headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq %w'FirstName LastName'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['FirstName']).to eq 'John'
          expect(row['LastName']).to eq 'Smith'
          expect(row['address']).to be_nil
          expect(row['phone']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 1
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['FirstName']).to eq 'John'
          expect(row['LastName']).to eq 'Smith'
          expect(row['address']).to be_nil
          expect(row['phone']).to be_nil
        end

      end

      context 'well-formed with optional headers' do
        let(:required_headers) {%w'FirstName LastName'}
        let(:optional_headers) {%w'address'}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains required and optional headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          optional_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq %w'FirstName LastName address'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['FirstName']).to eq 'John'
          expect(row['LastName']).to eq 'Smith'
          expect(row['address']).to eq 'mystreet 1, myplace'
          expect(row['phone']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 1
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['FirstName']).to eq 'John'
          expect(row['LastName']).to eq 'Smith'
          expect(row['address']).to eq 'mystreet 1, myplace'
          expect(row['phone']).to be_nil
        end

      end

      context 'missing optional headers' do

        let(:required_headers) {%w'FirstName LastName address'}
        let(:optional_headers) {%w'phone'}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains only required headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          optional_headers.each do |header|
            expect(ss.headers).not_to include header
          end
          expect(ss.headers).to eq %w'FirstName LastName address'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['FirstName']).to eq 'John'
          expect(row['LastName']).to eq 'Smith'
          expect(row['address']).to eq 'mystreet 1, myplace'
          expect(row['phone']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 1
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['FirstName']).to eq 'John'
          expect(row['LastName']).to eq 'Smith'
          expect(row['address']).to eq 'mystreet 1, myplace'
          expect(row['phone']).to be_nil
        end

      end

      context 'missing required header' do
        let(:required_headers) {%w'FirstName LastName address phone'}

        it 'throws error when opened' do
          expect {ss}.to raise_error(RuntimeError, 'Sheet does not contain enough columns.')
        end

      end

    end

  end

  context 'TSV file' do

    let(:options) { {
        col_sep: "\t",
        extension: 'csv'
    }}

    context 'with headers' do

      let(:file_name) {'test-headers.tsv'}

      context 'well-formed' do

        let(:required_headers) {%w'FirstName LastName'}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains expected headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq %w'FirstName LastName address'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['FirstName']).to eq 'John'
          expect(row['LastName']).to eq 'Smith'
          expect(row['address']).to eq 'mystreet 1, myplace'
          expect(row['phone']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 1
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['FirstName']).to eq 'John'
          expect(row['LastName']).to eq 'Smith'
          expect(row['address']).to eq 'mystreet 1, myplace'
          expect(row['phone']).to be_nil
        end

      end

      context 'not specified' do

        let(:required_headers) {[]}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains expected headers' do
          expect(ss.headers).to eq %w'FirstName LastName address'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['FirstName']).to eq 'John'
          expect(row['LastName']).to eq 'Smith'
          expect(row['address']).to eq 'mystreet 1, myplace'
          expect(row['phone']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 1
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['FirstName']).to eq 'John'
          expect(row['LastName']).to eq 'Smith'
          expect(row['address']).to eq 'mystreet 1, myplace'
          expect(row['phone']).to be_nil
        end

      end

      context 'not well-formed' do

        let(:required_headers) {%w'FirstName LastName address phone'}

        it 'throws error when opened' do
          expect {ss}.to raise_error(RuntimeError, 'Headers not found: ["phone"].')
        end
      end

    end

    context 'without headers' do
      let(:file_name) {'test-noheaders.tsv'}

      context 'well-formed and strict' do
        let(:required_headers) {%w'FirstName LastName'}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains only required headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq %w'FirstName LastName'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['FirstName']).to eq 'John'
          expect(row['LastName']).to eq 'Smith'
          expect(row['address']).to be_nil
          expect(row['phone']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 1
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['FirstName']).to eq 'John'
          expect(row['LastName']).to eq 'Smith'
          expect(row['address']).to be_nil
          expect(row['phone']).to be_nil
        end

      end

      context 'well-formed with optional headers' do
        let(:required_headers) {%w'FirstName LastName'}
        let(:optional_headers) {%w'address'}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains required and optional headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          optional_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq %w'FirstName LastName address'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['FirstName']).to eq 'John'
          expect(row['LastName']).to eq 'Smith'
          expect(row['address']).to eq 'mystreet 1, myplace'
          expect(row['phone']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 1
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['FirstName']).to eq 'John'
          expect(row['LastName']).to eq 'Smith'
          expect(row['address']).to eq 'mystreet 1, myplace'
          expect(row['phone']).to be_nil
        end

      end

      context 'missing optional headers' do

        let(:required_headers) {%w'FirstName LastName address'}
        let(:optional_headers) {%w'phone'}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains only required headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          optional_headers.each do |header|
            expect(ss.headers).not_to include header
          end
          expect(ss.headers).to eq %w'FirstName LastName address'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['FirstName']).to eq 'John'
          expect(row['LastName']).to eq 'Smith'
          expect(row['address']).to eq 'mystreet 1, myplace'
          expect(row['phone']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 1
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['FirstName']).to eq 'John'
          expect(row['LastName']).to eq 'Smith'
          expect(row['address']).to eq 'mystreet 1, myplace'
          expect(row['phone']).to be_nil
        end

      end

      context 'missing required header' do
        let(:required_headers) {%w'FirstName LastName address phone'}

        it 'throws error when opened' do
          expect {ss}.to raise_error(RuntimeError, 'Sheet does not contain enough columns.')
        end

      end

    end

  end

  context 'XLSX file' do

    let(:real_headers) {%w'Date Amount Code Remark'}
    # noinspection RubyStringKeysInHashInspection
    let(:header_row) {{'Date' => 'Date', 'Amount' => 'Amount', 'Code' => 'Code', 'Remark' => 'Remark'}}
    # noinspection RubyStringKeysInHashInspection
    let(:first_data_row) {{'Date' => Date.new(2016, 05, 10), 'Amount' => 1270.0, 'Code' => 1, 'Remark' => 'a'}}
    # noinspection RubyStringKeysInHashInspection
    let(:data_row_13) {{'Date' => Date.new(2016, 7, 1), 'Amount' => 3705.0, 'Code' => 3, 'Remark' => 'b'}}
  let(:size_with_headers) { 18 }
    let(:size_without_headers) { 17 }

    context 'with headers' do
      let(:file_name) {'test.xlsx|Expenses'}

      context 'well-formed' do

        let(:required_headers) {%w'Date Amount'}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains expected headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq real_headers
        end

        it 'each returns header and data rows' do
          expect(ss.each.count).to eq size_with_headers
          expect(ss.each.first).to eq header_row
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to eq first_data_row['Remark']
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq size_without_headers
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to eq first_data_row['Remark']
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq data_row_13['Date']
          expect(row['Amount']).to eq data_row_13['Amount']
          expect(row['Code']).to eq data_row_13['Code']
          expect(row['Remark']).to eq data_row_13['Remark']
          expect(row['dummy']).to be_nil
        end

      end

      context 'not specified' do

        let(:required_headers) {[]}


        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains expected headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq real_headers
        end

        it 'each returns header and data rows' do
          expect(ss.each.count).to eq size_with_headers
          expect(ss.each.first).to eq header_row
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to eq first_data_row['Remark']
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq size_without_headers
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to eq first_data_row['Remark']
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq data_row_13['Date']
          expect(row['Amount']).to eq data_row_13['Amount']
          expect(row['Code']).to eq data_row_13['Code']
          expect(row['Remark']).to eq data_row_13['Remark']
          expect(row['dummy']).to be_nil
        end

      end

      context 'not well-formed' do

        let(:required_headers) {%w'Date dummy1 Amount dummy2'}

        it 'throws error when opened' do
          expect {ss}.to raise_error(RuntimeError, 'Headers not found: ["dummy1", "dummy2"].')
        end
      end

    end

    context 'without headers' do
      let(:file_name) {'test.xlsx|ExpensesNoHeaders'}

      context 'well-formed and strict' do
        let(:required_headers) {%w'Date Amount'}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains only required headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq required_headers
        end

        it 'each returns header and data rows' do
          expect(ss.each.count).to eq size_with_headers
          expect(ss.each.first.keys).to eq required_headers
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to be_nil
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq size_without_headers
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to be_nil
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq data_row_13['Date']
          expect(row['Amount']).to eq data_row_13['Amount']
          expect(row['Code']).to be_nil
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

      end

      context 'well-formed with optional headers' do
        let(:required_headers) {%w'Date Amount'}
        let(:optional_headers) {%w'Code'}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains required and optional headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          optional_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq required_headers + optional_headers
        end

        it 'each returns header and data rows' do
          expect(ss.each.count).to eq size_with_headers
          expect(ss.each.first.keys).to eq required_headers + optional_headers
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq size_without_headers
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq data_row_13['Date']
          expect(row['Amount']).to eq data_row_13['Amount']
          expect(row['Code']).to eq data_row_13['Code']
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

      end

      context 'missing optional headers' do

        let(:required_headers) {%w'Date Amount Code Remark'}
        let(:optional_headers) {%w'dummy'}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains only required headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          optional_headers.each do |header|
            expect(ss.headers).not_to include header
          end
          expect(ss.headers).to eq required_headers
        end

        it 'each returns header and data rows' do
          expect(ss.each.count).to eq size_with_headers
          expect(ss.each.first.keys).to eq required_headers
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to eq first_data_row['Remark']
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq size_without_headers
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to eq first_data_row['Remark']
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq data_row_13['Date']
          expect(row['Amount']).to eq data_row_13['Amount']
          expect(row['Code']).to eq data_row_13['Code']
          expect(row['Remark']).to eq data_row_13['Remark']
          expect(row['dummy']).to be_nil
        end

      end

      context 'missing required header' do
        let(:required_headers) {%w'Date Amount Code Remark dummy'}

        it 'throws error when opened' do
          expect {ss}.to raise_error(RuntimeError, 'Sheet does not contain enough columns.')
        end

      end

    end

    context 'blank rows with headers' do
      let(:file_name) {'test.xlsx|ExpensesBlankRows'}

      context 'well-formed' do

        let(:required_headers) {%w'Date Amount'}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains expected headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq real_headers
        end

        it 'each returns header and data rows' do
          expect(ss.each.count).to eq size_with_headers
          expect(ss.each.first).to eq header_row
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to eq first_data_row['Remark']
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq size_without_headers
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to eq first_data_row['Remark']
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq data_row_13['Date']
          expect(row['Amount']).to eq data_row_13['Amount']
          expect(row['Code']).to eq data_row_13['Code']
          expect(row['Remark']).to eq data_row_13['Remark']
          expect(row['dummy']).to be_nil
        end

      end

      context 'not specified' do

        let(:required_headers) {[]}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains expected headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq real_headers
        end

        it 'each returns header and data rows' do
          expect(ss.each.count).to eq size_with_headers
          expect(ss.each.first).to eq header_row
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to eq first_data_row['Remark']
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq size_without_headers
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to eq first_data_row['Remark']
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq data_row_13['Date']
          expect(row['Amount']).to eq data_row_13['Amount']
          expect(row['Code']).to eq data_row_13['Code']
          expect(row['Remark']).to eq data_row_13['Remark']
          expect(row['dummy']).to be_nil
        end

      end

      context 'not well-formed' do

        let(:required_headers) {%w'Date dummy1 Amount dummy2'}

        it 'throws error when opened' do
          expect {ss}.to raise_error(RuntimeError, 'Headers not found: ["dummy1", "dummy2"].')
        end
      end

    end

    context 'blank rows without headers' do
      let(:file_name) {'test.xlsx|ExpensesBlankRowsNoHeaders'}

      context 'well-formed and strict' do
        let(:required_headers) {%w'Date Amount'}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains only required headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq required_headers
        end

        it 'each returns header and data rows' do
          expect(ss.each.count).to eq size_with_headers
          expect(ss.each.first.keys).to eq required_headers
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to be_nil
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq size_without_headers
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to be_nil
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq data_row_13['Date']
          expect(row['Amount']).to eq data_row_13['Amount']
          expect(row['Code']).to be_nil
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

      end

      context 'well-formed with optional headers' do
        let(:required_headers) {%w'Date Amount'}
        let(:optional_headers) {%w'Code'}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains required and optional headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          optional_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq required_headers + optional_headers
        end

        it 'each returns header and data rows' do
          expect(ss.each.count).to eq size_with_headers
          expect(ss.each.first.keys).to eq required_headers + optional_headers
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq size_without_headers
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq data_row_13['Date']
          expect(row['Amount']).to eq data_row_13['Amount']
          expect(row['Code']).to eq data_row_13['Code']
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

      end

      context 'missing optional headers' do

        let(:required_headers) {%w'Date Amount Code Remark'}
        let(:optional_headers) {%w'dummy'}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains only required headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          optional_headers.each do |header|
            expect(ss.headers).not_to include header
          end
          expect(ss.headers).to eq required_headers
        end

        it 'each returns header and data rows' do
          expect(ss.each.count).to eq size_with_headers
          expect(ss.each.first.keys).to eq required_headers
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to eq first_data_row['Remark']
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq size_without_headers
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to eq first_data_row['Remark']
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq data_row_13['Date']
          expect(row['Amount']).to eq data_row_13['Amount']
          expect(row['Code']).to eq data_row_13['Code']
          expect(row['Remark']).to eq data_row_13['Remark']
          expect(row['dummy']).to be_nil
        end

      end

      context 'missing required header' do
        let(:required_headers) {%w'Date Amount Code Remark dummy'}

        it 'throws error when opened' do
          expect {ss}.to raise_error(RuntimeError, 'Sheet does not contain enough columns.')
        end

      end

    end

    context 'blank columns with headers' do
      let(:file_name) {'test.xlsx|ExpensesBlankColumns'}

      context 'well-formed' do

        let(:required_headers) {%w'Date Amount'}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains expected headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq real_headers
        end

        it 'each returns header and data rows' do
          expect(ss.each.count).to eq size_with_headers
          expect(ss.each.first).to eq header_row
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to eq first_data_row['Remark']
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq size_without_headers
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to eq first_data_row['Remark']
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq data_row_13['Date']
          expect(row['Amount']).to eq data_row_13['Amount']
          expect(row['Code']).to eq data_row_13['Code']
          expect(row['Remark']).to eq data_row_13['Remark']
          expect(row['dummy']).to be_nil
        end

      end

      context 'not specified' do

        let(:required_headers) {[]}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains expected headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq real_headers
        end

        it 'each returns header and data rows' do
          expect(ss.each.count).to eq size_with_headers
          expect(ss.each.first).to eq header_row
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to eq first_data_row['Remark']
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq size_without_headers
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to eq first_data_row['Remark']
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq data_row_13['Date']
          expect(row['Amount']).to eq data_row_13['Amount']
          expect(row['Code']).to eq data_row_13['Code']
          expect(row['Remark']).to eq data_row_13['Remark']
          expect(row['dummy']).to be_nil
        end

      end

      context 'not well-formed' do

        let(:required_headers) {%w'Date dummy1 Amount dummy2'}

        it 'throws error when opened' do
          expect {ss}.to raise_error(RuntimeError, 'Headers not found: ["dummy1", "dummy2"].')
        end
      end

    end

    context 'blank columns without headers' do
      let(:file_name) {'test.xlsx|ExpensesBlankColumnsNoHeaders'}

      context 'well-formed and strict' do
        let(:required_headers) {%w'Date Amount'}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains only required headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq required_headers
        end

        it 'each returns header and data rows' do
          expect(ss.each.count).to eq size_with_headers
          expect(ss.each.first.keys).to eq required_headers
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to be_nil
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq size_without_headers
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to be_nil
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq data_row_13['Date']
          expect(row['Amount']).to eq data_row_13['Amount']
          expect(row['Code']).to be_nil
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

      end

      context 'well-formed with optional headers' do
        let(:required_headers) {%w'Date Amount'}
        let(:optional_headers) {%w'Code'}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains required and optional headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          optional_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq required_headers + optional_headers
        end

        it 'each returns header and data rows' do
          expect(ss.each.count).to eq size_with_headers
          expect(ss.each.first.keys).to eq required_headers + optional_headers
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq size_without_headers
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq data_row_13['Date']
          expect(row['Amount']).to eq data_row_13['Amount']
          expect(row['Code']).to eq data_row_13['Code']
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

      end

      context 'missing optional headers' do

        let(:required_headers) {%w'Date Amount Code Remark'}
        let(:optional_headers) {%w'dummy'}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains only required headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          optional_headers.each do |header|
            expect(ss.headers).not_to include header
          end
          expect(ss.headers).to eq required_headers
        end

        it 'each returns header and data rows' do
          expect(ss.each.count).to eq size_with_headers
          expect(ss.each.first.keys).to eq required_headers
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to eq first_data_row['Remark']
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq size_without_headers
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to eq first_data_row['Remark']
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq data_row_13['Date']
          expect(row['Amount']).to eq data_row_13['Amount']
          expect(row['Code']).to eq data_row_13['Code']
          expect(row['Remark']).to eq data_row_13['Remark']
          expect(row['dummy']).to be_nil
        end

      end

      context 'missing required header' do
        let(:required_headers) {%w'Date Amount Code Remark dummy'}

        it 'throws error when opened' do
          expect {ss}.to raise_error(RuntimeError, 'Sheet does not contain enough columns.')
        end

      end

    end

    context 'blank row and columns with headers' do
      let(:file_name) {'test.xlsx|ExpensesBlankRowsAndColumns'}

      context 'well-formed' do

        let(:required_headers) {%w'Date Amount'}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains expected headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq real_headers
        end

        it 'each returns header and data rows' do
          expect(ss.each.count).to eq size_with_headers
          expect(ss.each.first).to eq header_row
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to eq first_data_row['Remark']
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq size_without_headers
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to eq first_data_row['Remark']
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq data_row_13['Date']
          expect(row['Amount']).to eq data_row_13['Amount']
          expect(row['Code']).to eq data_row_13['Code']
          expect(row['Remark']).to eq data_row_13['Remark']
          expect(row['dummy']).to be_nil
        end

      end

      context 'not specified' do

        let(:required_headers) {[]}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains expected headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq real_headers
        end

        it 'each returns header and data rows' do
          expect(ss.each.count).to eq size_with_headers
          expect(ss.each.first).to eq header_row
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to eq first_data_row['Remark']
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq size_without_headers
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to eq first_data_row['Remark']
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq data_row_13['Date']
          expect(row['Amount']).to eq data_row_13['Amount']
          expect(row['Code']).to eq data_row_13['Code']
          expect(row['Remark']).to eq data_row_13['Remark']
          expect(row['dummy']).to be_nil
        end

      end

      context 'not well-formed' do

        let(:required_headers) {%w'Date dummy1 Amount dummy2'}

        it 'throws error when opened' do
          expect {ss}.to raise_error(RuntimeError, 'Headers not found: ["dummy1", "dummy2"].')
        end
      end

    end

    context 'blank row and columns without headers' do
      let(:file_name) {'test.xlsx|ExpensesBlankRowsAndColumnsNoH'}

      context 'well-formed and strict' do
        let(:required_headers) {%w'Date Amount'}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains only required headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq required_headers
        end

        it 'each returns header and data rows' do
          expect(ss.each.count).to eq size_with_headers
          expect(ss.each.first.keys).to eq required_headers
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to be_nil
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq size_without_headers
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to be_nil
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq data_row_13['Date']
          expect(row['Amount']).to eq data_row_13['Amount']
          expect(row['Code']).to be_nil
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

      end

      context 'well-formed with optional headers' do
        let(:required_headers) {%w'Date Amount'}
        let(:optional_headers) {%w'Code'}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains required and optional headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          optional_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq required_headers + optional_headers
        end

        it 'each returns header and data rows' do
          expect(ss.each.count).to eq size_with_headers
          expect(ss.each.first.keys).to eq required_headers + optional_headers
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq size_without_headers
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq data_row_13['Date']
          expect(row['Amount']).to eq data_row_13['Amount']
          expect(row['Code']).to eq data_row_13['Code']
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

      end

      context 'missing optional headers' do

        let(:required_headers) {%w'Date Amount Code Remark'}
        let(:optional_headers) {%w'dummy'}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains only required headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          optional_headers.each do |header|
            expect(ss.headers).not_to include header
          end
          expect(ss.headers).to eq required_headers
        end

        it 'each returns header and data rows' do
          expect(ss.each.count).to eq size_with_headers
          expect(ss.each.first.keys).to eq required_headers
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to eq first_data_row['Remark']
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq size_without_headers
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq first_data_row['Date']
          expect(row['Amount']).to eq first_data_row['Amount']
          expect(row['Code']).to eq first_data_row['Code']
          expect(row['Remark']).to eq first_data_row['Remark']
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq data_row_13['Date']
          expect(row['Amount']).to eq data_row_13['Amount']
          expect(row['Code']).to eq data_row_13['Code']
          expect(row['Remark']).to eq data_row_13['Remark']
          expect(row['dummy']).to be_nil
        end

      end

      context 'missing required header' do
        let(:required_headers) {%w'Date Amount Code Remark dummy'}

        it 'throws error when opened' do
          expect {ss}.to raise_error(RuntimeError, 'Sheet does not contain enough columns.')
        end

      end

    end

    context 'Only headers' do
      let(:file_name) {'test.xlsx|ExpensesOnlyHeaders'}

      context 'well-formed' do

        let(:required_headers) {%w'Date Amount'}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains expected headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq real_headers
        end

        it 'each returns header and data rows' do
          expect(ss.each.count).to be 1
          expect(ss.each.first).to eq header_row
        end

        it '#shift returns nil' do
          row = ss.shift
          expect(row).to be_nil
        end

        it '#parse returns empty Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          # noinspection RubyResolve
          expect(rows).to be_empty
          expect(rows.size).to eq 0
        end

      end

      context 'not specified' do

        let(:required_headers) {[]}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains expected headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq %w'Date Amount Code Remark'
        end

        it '#shift returns nil' do
          row = ss.shift
          expect(row).to be_nil
        end

        it '#parse returns empty Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          # noinspection RubyResolve
          expect(rows).to be_empty
          expect(rows.size).to eq 0
        end

      end

      context 'not well-formed' do

        let(:required_headers) {%w'Date dummy1 Amount dummy2'}

        it 'throws error when opened' do
          expect {ss}.to raise_error(RuntimeError, 'Headers not found: ["dummy1", "dummy2"].')
        end
      end

    end

    context 'Only headers with blank rows and columns' do
      let(:file_name) {'test.xlsx|ExpensesOnlyHeadersBlankRowsAndColumns'}

      context 'well-formed' do

        let(:required_headers) {%w'Date Amount'}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains expected headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq %w'Date Amount Code Remark'
        end

        it '#shift returns nil' do
          row = ss.shift
          expect(row).to be_nil
        end

        it '#parse returns empty Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          # noinspection RubyResolve
          expect(rows).to be_empty
          expect(rows.size).to eq 0
        end

      end

      context 'not specified' do

        let(:required_headers) {[]}

        it 'opens correctly' do
          expect {ss}.not_to raise_error
        end

        it 'contains expected headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq %w'Date Amount Code Remark'
        end

        it '#shift returns nil' do
          row = ss.shift
          expect(row).to be_nil
        end

        it '#parse returns empty Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          # noinspection RubyResolve
          expect(rows).to be_empty
          expect(rows.size).to eq 0
        end

      end

      context 'not well-formed' do

        let(:required_headers) {%w'Date dummy1 Amount dummy2'}

        it 'throws error when opened' do
          expect {ss}.to raise_error(RuntimeError, 'Headers not found: ["dummy1", "dummy2"].')
        end
      end

    end

  end

end