# encoding: utf-8
require_relative 'spec_helper'
require 'libis/tools/temp_file'

describe 'TempFile' do

  context 'name' do

    it 'without arguments' do
      fname = Libis::Tools::TempFile.name()
      expect(File.basename(fname)).to match(/^\d{8}_\d+_\w+$/)
    end

    it 'with prefix' do
      fname = Libis::Tools::TempFile.name('abc')
      expect(File.basename(fname)).to match(/^abc_\d{8}_\d+_\w+$/)
    end

    it 'with suffix' do
      fname = Libis::Tools::TempFile.name(nil, '.xyz')
      expect(File.basename(fname)).to match(/^\d{8}_\d+_\w+\.xyz$/)
    end

    it 'with prefix and suffix' do
      fname = Libis::Tools::TempFile.name('abc', '.xyz')
      expect(File.basename(fname)).to match(/^abc_\d{8}_\d+_\w+\.xyz$/)
    end

    it 'not in temp dir' do
      fname = Libis::Tools::TempFile.name(nil, nil, '/abc/xyz/')
      expect(File.dirname(fname)).to match('/abc/xyz')
    end

  end

  context 'file' do

    it 'created' do
      f = Libis::Tools::TempFile.file
      expect(File.exist?(f.path)).to be_truthy
      f.close
      f.delete
    end

    it 'is open' do
      f = Libis::Tools::TempFile.file
      expect(f.closed?).to be_falsey
      f.close
      f.delete
    end

    it 'can be closed' do
      f = Libis::Tools::TempFile.file
      expect(f.closed?).to be_falsey
      f.close
      expect(f.closed?).to be_truthy
      f.delete
    end

    it 'can be unlinked' do
      f = Libis::Tools::TempFile.file
      f.close
      f.unlink
      expect(File.exist?(f.path)).to be_falsey
    end

    it 'can be deleted' do
      f = Libis::Tools::TempFile.file
      f.close
      f.delete
      expect(File.exist?(f.path)).to be_falsey
    end

  end

end
