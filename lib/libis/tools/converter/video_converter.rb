# coding: utf-8

require_relative 'base'

class VideoConverter < Base

  private

  TYPES = [:MPEG, :MPEG4, :MJPEG2000, :QUICKTIME, :AVI, :OGGV, :WMV]

  protected

  def self.input_types
    TYPES
  end

  def self.output_types
    TYPES
  end

  def init(source)
    puts "Initializing #{self.class} with '#{source}'"
  end

  def do_convert(target, format)
    puts "#{self.class}::do_convert(#{target},#{format}) not implemented yet."
  end

end
