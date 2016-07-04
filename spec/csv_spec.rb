# encoding: utf-8
require_relative 'spec_helper'
require 'rspec/matchers'
require 'libis/tools/csv'

describe 'CSV File' do

  let(:path) { File.absolute_path('data', File.dirname(__FILE__)) }
  let(:csv) {
    Libis::Tools::Csv.open(
        File.join(path, csv_file),
        required: required_headers,
        optional: optional_headers
    )
  }

  let(:optional_headers) { [] }

  after(:example) { csv.close rescue nil }

  context 'with headers' do
    let(:csv_file) { 'test-headers.csv' }

    context 'well-formed' do

      let(:required_headers) { %w'FirstName LastName' }

      it 'opens correctly' do
        expect{ csv }.not_to raise_error
      end

      it 'contains expected headers' do
        required_headers.each do |header|
          expect(csv.headers).to include header
        end
        expect(csv.headers).to eq %w'FirstName LastName address'
      end

      it '#shift returns Row object' do
        row = csv.shift
        expect(row).to be_a CSV::Row
        expect(row['FirstName']).to eq 'John'
        expect(row['LastName']).to eq 'Smith'
        expect(row['address']).to eq 'mystreet 1, myplace'
        expect(row['phone']).to be_nil
      end

    end

    context 'not well-formed' do

      let(:required_headers) { %w'FirstName LastName address phone'}

      it 'throws error when opened' do
        expect { csv }.to raise_error(RuntimeError, 'CSV headers not found: ["phone"]')
      end
    end

  end

  context 'without headers' do
    let(:csv_file) { 'test-noheaders.csv' }

    context 'well-formed and strict' do
      let(:required_headers) { %w'FirstName LastName' }

      it 'opens correctly' do
        expect { csv }.not_to raise_error
      end

      it 'contains only required headers' do
        required_headers.each do |header|
          expect(csv.headers).to include header
        end
        expect(csv.headers).to eq %w'FirstName LastName'
      end

      it '#shift returns Row object' do
        row = csv.shift
        expect(row).to be_a CSV::Row
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
        expect { csv }.not_to raise_error
      end

      it 'contains required and optional headers' do
        required_headers.each do |header|
          expect(csv.headers).to include header
        end
        optional_headers.each do |header|
          expect(csv.headers).to include header
        end
        expect(csv.headers).to eq %w'FirstName LastName address'
      end

      it '#shift returns Row object' do
        row = csv.shift
        expect(row).to be_a CSV::Row
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
        expect { csv }.not_to raise_error
      end

      it 'contains only required headers' do
        required_headers.each do |header|
          expect(csv.headers).to include header
        end
        optional_headers.each do |header|
          expect(csv.headers).not_to include header
        end
        expect(csv.headers).to eq %w'FirstName LastName address'
      end

      it '#shift returns Row object' do
        row = csv.shift
        expect(row).to be_a CSV::Row
        expect(row['FirstName']).to eq 'John'
        expect(row['LastName']).to eq 'Smith'
        expect(row['address']).to eq 'mystreet 1, myplace'
        expect(row['phone']).to be_nil
      end

    end

    context 'missing required header' do
      let(:required_headers) { %w'FirstName LastName address phone'}

      it 'throws error when opened' do
        expect { csv }.to raise_error(RuntimeError, 'CSV does not contain enough columns')
      end

    end

  end

end