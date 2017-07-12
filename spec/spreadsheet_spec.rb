# encoding: utf-8
require_relative 'spec_helper'
require 'rspec/matchers'
require 'libis/tools/spreadsheet'

describe 'Libis::Tools::Spreadsheet' do

  let(:path) { File.absolute_path('data', File.dirname(__FILE__)) }
  let(:ss) {
    Libis::Tools::Spreadsheet.new(
        File.join(path, file_name),
        required: required_headers,
        optional: optional_headers
    )
  }

  let(:optional_headers) { [] }

  context 'CSV file' do
    context 'with headers' do
      let(:file_name) { 'test-headers.csv' }

      context 'well-formed' do

        let(:required_headers) { %w'FirstName LastName' }

        it 'opens correctly' do
          expect{ ss }.not_to raise_error
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

        let(:required_headers) { [] }

        it 'opens correctly' do
          expect{ ss }.not_to raise_error
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

        let(:required_headers) { %w'FirstName LastName address phone'}

        it 'throws error when opened' do
          expect { ss }.to raise_error(RuntimeError, 'Headers not found: ["phone"].')
        end
      end

    end

    context 'without headers' do
      let(:file_name) { 'test-noheaders.csv' }

      context 'well-formed and strict' do
        let(:required_headers) { %w'FirstName LastName' }

        it 'opens correctly' do
          expect { ss }.not_to raise_error
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
        let(:required_headers) { %w'FirstName LastName' }
        let(:optional_headers) { %w'address' }

        it 'opens correctly' do
          expect { ss }.not_to raise_error
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

        let(:required_headers) { %w'FirstName LastName address' }
        let(:optional_headers) { %w'phone' }

        it 'opens correctly' do
          expect { ss }.not_to raise_error
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
        let(:required_headers) { %w'FirstName LastName address phone'}

        it 'throws error when opened' do
          expect { ss }.to raise_error(RuntimeError, 'Sheet does not contain enough columns.')
        end

      end

    end

  end

  context 'XLSX file' do
    # let(:ss) {
    #   Libis::Tools::Spreadsheet.new(
    #       File.join(path, file_name),
    #       required: required_headers,
    #       optional: optional_headers,
    #       extension: :xlsx
    #   )
    # }

    context 'with headers' do
      let(:file_name) { 'test.xlsx|Expenses' }

      context 'well-formed' do

        let(:required_headers) { %w'Date Amount' }

        it 'opens correctly' do
          expect{ ss }.not_to raise_error
        end

        it 'contains expected headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq %w'Date Amount Code Remark'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016, 05, 10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to eq 'a'
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 17
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,5,10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to eq 'a'
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,7,1)
          expect(row['Amount']).to eq 3705.0
          expect(row['Code']).to eq 3
          expect(row['Remark']).to eq 'b'
          expect(row['dummy']).to be_nil
        end

      end

      context 'not specified' do

        let(:required_headers) { [] }

        it 'opens correctly' do
          expect{ ss }.not_to raise_error
        end

        it 'contains expected headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq %w'Date Amount Code Remark'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016, 05, 10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to eq 'a'
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 17
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,5,10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to eq 'a'
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,7,1)
          expect(row['Amount']).to eq 3705.0
          expect(row['Code']).to eq 3
          expect(row['Remark']).to eq 'b'
          expect(row['dummy']).to be_nil
        end

      end

      context 'not well-formed' do

        let(:required_headers) { %w'Date dummy1 Amount dummy2'}

        it 'throws error when opened' do
          expect { ss }.to raise_error(RuntimeError, 'Headers not found: ["dummy1", "dummy2"].')
        end
      end

    end

    context 'without headers' do
      let(:file_name) { 'test.xlsx|ExpensesNoHeaders' }

      context 'well-formed and strict' do
        let(:required_headers) { %w'Date Amount' }

        it 'opens correctly' do
          expect { ss }.not_to raise_error
        end

        it 'contains only required headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq %w'Date Amount'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016, 05, 10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to be_nil
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 17
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,5,10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to be_nil
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,7,1)
          expect(row['Amount']).to eq 3705.0
          expect(row['Code']).to be_nil
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

      end

      context 'well-formed with optional headers' do
        let(:required_headers) { %w'Date Amount' }
        let(:optional_headers) { %w'Code' }

        it 'opens correctly' do
          expect { ss }.not_to raise_error
        end

        it 'contains required and optional headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          optional_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq %w'Date Amount Code'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016, 05, 10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 17
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,5,10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,7,1)
          expect(row['Amount']).to eq 3705.0
          expect(row['Code']).to eq 3
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

      end

      context 'missing optional headers' do

        let(:required_headers) { %w'Date Amount Code Remark' }
        let(:optional_headers) { %w'dummy' }

        it 'opens correctly' do
          expect { ss }.not_to raise_error
        end

        it 'contains only required headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          optional_headers.each do |header|
            expect(ss.headers).not_to include header
          end
          expect(ss.headers).to eq %w'Date Amount Code Remark'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016, 05, 10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to eq 'a'
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 17
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,5,10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to eq 'a'
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,7,1)
          expect(row['Amount']).to eq 3705.0
          expect(row['Code']).to eq 3
          expect(row['Remark']).to eq 'b'
          expect(row['dummy']).to be_nil
        end

      end

      context 'missing required header' do
        let(:required_headers) { %w'Date Amount Code Remark dummy' }

        it 'throws error when opened' do
          expect { ss }.to raise_error(RuntimeError, 'Sheet does not contain enough columns.')
        end

      end

    end

    context 'blank rows with headers' do
      let(:file_name) { 'test.xlsx|ExpensesBlankRows' }

      context 'well-formed' do

        let(:required_headers) { %w'Date Amount' }

        it 'opens correctly' do
          expect{ ss }.not_to raise_error
        end

        it 'contains expected headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq %w'Date Amount Code Remark'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016, 05, 10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to eq 'a'
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 17
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,5,10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to eq 'a'
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,7,1)
          expect(row['Amount']).to eq 3705.0
          expect(row['Code']).to eq 3
          expect(row['Remark']).to eq 'b'
          expect(row['dummy']).to be_nil
        end

      end

      context 'not specified' do

        let(:required_headers) { [] }

        it 'opens correctly' do
          expect{ ss }.not_to raise_error
        end

        it 'contains expected headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq %w'Date Amount Code Remark'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016, 05, 10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to eq 'a'
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 17
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,5,10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to eq 'a'
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,7,1)
          expect(row['Amount']).to eq 3705.0
          expect(row['Code']).to eq 3
          expect(row['Remark']).to eq 'b'
          expect(row['dummy']).to be_nil
        end

      end

      context 'not well-formed' do

        let(:required_headers) { %w'Date dummy1 Amount dummy2'}

        it 'throws error when opened' do
          expect { ss }.to raise_error(RuntimeError, 'Headers not found: ["dummy1", "dummy2"].')
        end
      end

    end

    context 'blank rows without headers' do
      let(:file_name) { 'test.xlsx|ExpensesBlankRowsNoHeaders' }

      context 'well-formed and strict' do
        let(:required_headers) { %w'Date Amount' }

        it 'opens correctly' do
          expect { ss }.not_to raise_error
        end

        it 'contains only required headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq %w'Date Amount'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016, 05, 10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to be_nil
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 17
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,5,10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to be_nil
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,7,1)
          expect(row['Amount']).to eq 3705.0
          expect(row['Code']).to be_nil
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

      end

      context 'well-formed with optional headers' do
        let(:required_headers) { %w'Date Amount' }
        let(:optional_headers) { %w'Code' }

        it 'opens correctly' do
          expect { ss }.not_to raise_error
        end

        it 'contains required and optional headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          optional_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq %w'Date Amount Code'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016, 05, 10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 17
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,5,10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,7,1)
          expect(row['Amount']).to eq 3705.0
          expect(row['Code']).to eq 3
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

      end

      context 'missing optional headers' do

        let(:required_headers) { %w'Date Amount Code Remark' }
        let(:optional_headers) { %w'dummy' }

        it 'opens correctly' do
          expect { ss }.not_to raise_error
        end

        it 'contains only required headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          optional_headers.each do |header|
            expect(ss.headers).not_to include header
          end
          expect(ss.headers).to eq %w'Date Amount Code Remark'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016, 05, 10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to eq 'a'
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 17
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,5,10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to eq 'a'
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,7,1)
          expect(row['Amount']).to eq 3705.0
          expect(row['Code']).to eq 3
          expect(row['Remark']).to eq 'b'
          expect(row['dummy']).to be_nil
        end

      end

      context 'missing required header' do
        let(:required_headers) { %w'Date Amount Code Remark dummy' }

        it 'throws error when opened' do
          expect { ss }.to raise_error(RuntimeError, 'Sheet does not contain enough columns.')
        end

      end

    end

    context 'blank columns with headers' do
      let(:file_name) { 'test.xlsx|ExpensesBlankColumns' }

      context 'well-formed' do

        let(:required_headers) { %w'Date Amount' }

        it 'opens correctly' do
          expect{ ss }.not_to raise_error
        end

        it 'contains expected headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq %w'Date Amount Code Remark'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016, 05, 10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to eq 'a'
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 17
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,5,10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to eq 'a'
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,7,1)
          expect(row['Amount']).to eq 3705.0
          expect(row['Code']).to eq 3
          expect(row['Remark']).to eq 'b'
          expect(row['dummy']).to be_nil
        end

      end

      context 'not specified' do

        let(:required_headers) { [] }

        it 'opens correctly' do
          expect{ ss }.not_to raise_error
        end

        it 'contains expected headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq %w'Date Amount Code Remark'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016, 05, 10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to eq 'a'
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 17
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,5,10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to eq 'a'
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,7,1)
          expect(row['Amount']).to eq 3705.0
          expect(row['Code']).to eq 3
          expect(row['Remark']).to eq 'b'
          expect(row['dummy']).to be_nil
        end

      end

      context 'not well-formed' do

        let(:required_headers) { %w'Date dummy1 Amount dummy2'}

        it 'throws error when opened' do
          expect { ss }.to raise_error(RuntimeError, 'Headers not found: ["dummy1", "dummy2"].')
        end
      end

    end

    context 'blank columns without headers' do
      let(:file_name) { 'test.xlsx|ExpensesBlankColumnsNoHeaders' }

      context 'well-formed and strict' do
        let(:required_headers) { %w'Date Amount' }

        it 'opens correctly' do
          expect { ss }.not_to raise_error
        end

        it 'contains only required headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq %w'Date Amount'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016, 05, 10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to be_nil
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 17
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,5,10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to be_nil
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,7,1)
          expect(row['Amount']).to eq 3705.0
          expect(row['Code']).to be_nil
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

      end

      context 'well-formed with optional headers' do
        let(:required_headers) { %w'Date Amount' }
        let(:optional_headers) { %w'Code' }

        it 'opens correctly' do
          expect { ss }.not_to raise_error
        end

        it 'contains required and optional headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          optional_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq %w'Date Amount Code'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016, 05, 10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 17
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,5,10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,7,1)
          expect(row['Amount']).to eq 3705.0
          expect(row['Code']).to eq 3
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

      end

      context 'missing optional headers' do

        let(:required_headers) { %w'Date Amount Code Remark' }
        let(:optional_headers) { %w'dummy' }

        it 'opens correctly' do
          expect { ss }.not_to raise_error
        end

        it 'contains only required headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          optional_headers.each do |header|
            expect(ss.headers).not_to include header
          end
          expect(ss.headers).to eq %w'Date Amount Code Remark'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016, 05, 10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to eq 'a'
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 17
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,5,10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to eq 'a'
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,7,1)
          expect(row['Amount']).to eq 3705.0
          expect(row['Code']).to eq 3
          expect(row['Remark']).to eq 'b'
          expect(row['dummy']).to be_nil
        end

      end

      context 'missing required header' do
        let(:required_headers) { %w'Date Amount Code Remark dummy' }

        it 'throws error when opened' do
          expect { ss }.to raise_error(RuntimeError, 'Sheet does not contain enough columns.')
        end

      end

    end

    context 'blank row and columns with headers' do
      let(:file_name) { 'test.xlsx|ExpensesBlankRowsAndColumns' }

      context 'well-formed' do

        let(:required_headers) { %w'Date Amount' }

        it 'opens correctly' do
          expect{ ss }.not_to raise_error
        end

        it 'contains expected headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq %w'Date Amount Code Remark'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016, 05, 10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to eq 'a'
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 17
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,5,10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to eq 'a'
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,7,1)
          expect(row['Amount']).to eq 3705.0
          expect(row['Code']).to eq 3
          expect(row['Remark']).to eq 'b'
          expect(row['dummy']).to be_nil
        end

      end

      context 'not specified' do

        let(:required_headers) { [] }

        it 'opens correctly' do
          expect{ ss }.not_to raise_error
        end

        it 'contains expected headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq %w'Date Amount Code Remark'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016, 05, 10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to eq 'a'
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 17
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,5,10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to eq 'a'
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,7,1)
          expect(row['Amount']).to eq 3705.0
          expect(row['Code']).to eq 3
          expect(row['Remark']).to eq 'b'
          expect(row['dummy']).to be_nil
        end

      end

      context 'not well-formed' do

        let(:required_headers) { %w'Date dummy1 Amount dummy2'}

        it 'throws error when opened' do
          expect { ss }.to raise_error(RuntimeError, 'Headers not found: ["dummy1", "dummy2"].')
        end
      end

    end

    context 'blank row and columns without headers' do
      let(:file_name) { 'test.xlsx|ExpensesBlankRowsAndColumnsNoH' }

      context 'well-formed and strict' do
        let(:required_headers) { %w'Date Amount' }

        it 'opens correctly' do
          expect { ss }.not_to raise_error
        end

        it 'contains only required headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq %w'Date Amount'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016, 05, 10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to be_nil
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 17
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,5,10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to be_nil
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,7,1)
          expect(row['Amount']).to eq 3705.0
          expect(row['Code']).to be_nil
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

      end

      context 'well-formed with optional headers' do
        let(:required_headers) { %w'Date Amount' }
        let(:optional_headers) { %w'Code' }

        it 'opens correctly' do
          expect { ss }.not_to raise_error
        end

        it 'contains required and optional headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          optional_headers.each do |header|
            expect(ss.headers).to include header
          end
          expect(ss.headers).to eq %w'Date Amount Code'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016, 05, 10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 17
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,5,10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,7,1)
          expect(row['Amount']).to eq 3705.0
          expect(row['Code']).to eq 3
          expect(row['Remark']).to be_nil
          expect(row['dummy']).to be_nil
        end

      end

      context 'missing optional headers' do

        let(:required_headers) { %w'Date Amount Code Remark' }
        let(:optional_headers) { %w'dummy' }

        it 'opens correctly' do
          expect { ss }.not_to raise_error
        end

        it 'contains only required headers' do
          required_headers.each do |header|
            expect(ss.headers).to include header
          end
          optional_headers.each do |header|
            expect(ss.headers).not_to include header
          end
          expect(ss.headers).to eq %w'Date Amount Code Remark'
        end

        it '#shift returns Hash object' do
          row = ss.shift
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016, 05, 10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to eq 'a'
          expect(row['dummy']).to be_nil
        end

        it '#parse returns Array of Hash objects' do
          rows = ss.parse
          expect(rows).to be_a Array
          expect(rows.size).to eq 17
          row = rows[0]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,5,10)
          expect(row['Amount']).to eq 1270.0
          expect(row['Code']).to eq 1
          expect(row['Remark']).to eq 'a'
          expect(row['dummy']).to be_nil
          row = rows[13]
          expect(row).to be_a Hash
          expect(row['Date']).to eq Date.new(2016,7,1)
          expect(row['Amount']).to eq 3705.0
          expect(row['Code']).to eq 3
          expect(row['Remark']).to eq 'b'
          expect(row['dummy']).to be_nil
        end

      end

      context 'missing required header' do
        let(:required_headers) { %w'Date Amount Code Remark dummy' }

        it 'throws error when opened' do
          expect { ss }.to raise_error(RuntimeError, 'Sheet does not contain enough columns.')
        end

      end

    end

  end

end