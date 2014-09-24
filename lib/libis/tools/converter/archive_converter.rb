# coding: utf-8

require_relative 'base'

class ArchiveConverter < Base

  private

  INPUT_TYPES = [:EAD]
  OUTPUT_TYPES = [:PDF]

  protected

  def self.input_types
    INPUT_TYPES
  end

  def self.output_types
    OUTPUT_TYPES
  end

  def init(source)
    puts "Initializing #{self.class} with '#{source}'"
  end

  def do_convert(target, format)
    puts "#{self.class}::do_convert(#{target},#{format}) not implemented yet."
  end

end
