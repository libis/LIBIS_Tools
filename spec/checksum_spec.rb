# encoding: utf-8
require_relative 'spec_helper'
require 'libis/tools/checksum'

describe 'Checksum' do

  file = File.absolute_path(File.join(File.dirname(__FILE__), 'data', 'test.data'))

  def hex2base64(hexdigest)
    [[hexdigest].pack('H*')].pack('m0')
  end

  def hex2string(hexdigest)
    [hexdigest].pack('H*')
  end

  it 'should calculate MD5 checksum' do

    checksum_type = :MD5
    digest = 'fe249d8dd45a39793f315fb0734ffe2c'
    expect(::Libis::Tools::Checksum.hexdigest(file, checksum_type)).to eq digest
    expect(::Libis::Tools::Checksum.base64digest(file, checksum_type)).to eq hex2base64(digest)
    expect(::Libis::Tools::Checksum.digest(file, checksum_type)).to eq hex2string(digest)

    checksum = ::Libis::Tools::Checksum.new(checksum_type)

    expect(checksum.hexdigest(file)).to eq digest
    expect(checksum.base64digest(file)).to eq hex2base64(digest)
    expect(checksum.digest(file)).to eq hex2string(digest)

  end

  it 'should calculate RMD160 checksum' do

    unless defined? JRUBY_VERSION

      checksum_type = :RMD160

      digest = '17c9eaad9ccbaad0e030c2c5d60fd9d58255cc39'
      expect(::Libis::Tools::Checksum.hexdigest(file, checksum_type)).to eq digest
      expect(::Libis::Tools::Checksum.base64digest(file, checksum_type)).to eq hex2base64(digest)
      expect(::Libis::Tools::Checksum.digest(file, checksum_type)).to eq hex2string(digest)

      checksum = ::Libis::Tools::Checksum.new(checksum_type)

      expect(checksum.hexdigest(file)).to eq digest
      expect(checksum.base64digest(file)).to eq hex2base64(digest)
      expect(checksum.digest(file)).to eq hex2string(digest)

    end

  end

  it 'should calculate SHA1 checksum' do

    checksum_type = :SHA1

    digest = 'e8f322d186699807a98a0cefb5015acf1554f954'
    expect(::Libis::Tools::Checksum.hexdigest(file, checksum_type)).to eq digest
    expect(::Libis::Tools::Checksum.base64digest(file, checksum_type)).to eq hex2base64(digest)
    expect(::Libis::Tools::Checksum.digest(file, checksum_type)).to eq hex2string(digest)

    checksum = ::Libis::Tools::Checksum.new(checksum_type)

    expect(checksum.hexdigest(file)).to eq digest
    expect(checksum.base64digest(file)).to eq hex2base64(digest)
    expect(checksum.digest(file)).to eq hex2string(digest)

  end

  it 'should calculate SHA256 checksum' do

    checksum_type = :SHA256

    digest = '2a742e643dd79427738bdc0ebd0d2837f998fe2101a964c2d5014905d331bbc4'
    expect(::Libis::Tools::Checksum.hexdigest(file, checksum_type)).to eq digest
    expect(::Libis::Tools::Checksum.base64digest(file, checksum_type)).to eq hex2base64(digest)
    expect(::Libis::Tools::Checksum.digest(file, checksum_type)).to eq hex2string(digest)

    checksum = ::Libis::Tools::Checksum.new(checksum_type)

    expect(checksum.hexdigest(file)).to eq digest
    expect(checksum.base64digest(file)).to eq hex2base64(digest)
    expect(checksum.digest(file)).to eq hex2string(digest)

  end

  it 'should calculate SHA384 checksum' do

    checksum_type = :SHA384

    digest = '71083b74394f49db6149ad9147103f7693ec823183750ce32a2215bbd7ee5e75212e2d794243c7e76c7318a4ddcf9a56'
    expect(::Libis::Tools::Checksum.hexdigest(file, checksum_type)).to eq digest
    expect(::Libis::Tools::Checksum.base64digest(file, checksum_type)).to eq hex2base64(digest)
    expect(::Libis::Tools::Checksum.digest(file, checksum_type)).to eq hex2string(digest)

    checksum = ::Libis::Tools::Checksum.new(checksum_type)

    expect(checksum.hexdigest(file)).to eq digest
    expect(checksum.base64digest(file)).to eq hex2base64(digest)
    expect(checksum.digest(file)).to eq hex2string(digest)

  end

  it 'should calculate SHA512 checksum' do

    checksum_type = :SHA512

    digest = '10964f5272729c2670ccad67754284fb06cca1387270c184c2edbcd032700548297916c8e109a10e019c25b86c646e95a3456c465f83d571502889f97b483e6f'
    expect(::Libis::Tools::Checksum.hexdigest(file, checksum_type)).to eq digest
    expect(::Libis::Tools::Checksum.base64digest(file, checksum_type)).to eq hex2base64(digest)
    expect(::Libis::Tools::Checksum.digest(file, checksum_type)).to eq hex2string(digest)

    checksum = ::Libis::Tools::Checksum.new(checksum_type)

    expect(checksum.hexdigest(file)).to eq digest
    expect(checksum.base64digest(file)).to eq hex2base64(digest)
    expect(checksum.digest(file)).to eq hex2string(digest)

  end

  it 'should not know how to calculate ABC checksum' do

    checksum_type = :ABC

    expect {
      ::Libis::Tools::Checksum.hexdigest(file, checksum_type)
    }.to raise_error(RuntimeError, "Checksum type 'ABC' not supported.")

  end

end