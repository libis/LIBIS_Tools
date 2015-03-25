class String

  def blank?
    self == ''
  end unless method_defined? :blank?

  def sort_form
    result = []
    matcher = /^(\D*)(\d*)(.*)$/
    self.split('.').each { |s|
      while !s.empty? and (x = matcher.match s)
        a = x[1].to_s.strip
        b = a.gsub(/[ _]/, '')
        result << [b.downcase, b, a]
        result << x[2].to_i
        s = x[3]
      end
    }
    result
  end unless method_defined? :sort_form

  def underscore
    self.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
        gsub(/([a-z\d])([A-Z])/, '\1_\2').
        tr('-', '_').
        downcase
  end unless method_defined? :underscore

  def quote
    '\"' + self.gsub(/"/) { |s| '\\' + s[0] } + '\"'
  end unless method_defined? :quote

  def escape_for_regexp
    self.gsub(/[\.\+\*\(\)\{\}\|\/\\\^\$"']/) { |s| '\\' + s[0].to_s }
  end

  def escape_for_string
    self.gsub(/"/) { |s| '\\' + s[0].to_s }
  end

  def escape_for_cmd
    self.gsub(/"/) { |s| '\\\\\\' + s[0].to_s }
  end

  def escape_for_sql
    self.gsub(/'/) { |s| ($` == '' || $' == '' ? '' : '\'') + s[0].to_s }
  end

  def dot_net_clean
    self.gsub /^(\d+|error|float|string);\\?#/, ''
  end

  def remove_whitespace
    self.gsub(/\s/, '_')
  end

  def encode_visual(regex = nil)
    regex ||= /\W/
    self.gsub(regex) { |c| '_x' + '%04x' % c.unpack('U')[0] + '_'}
  end unless method_defined? :encode_visual

  def decode_visual
    self.gsub(/_x([0-9a-f]{4})_/i) { [$1.to_i(16)].pack('U') }
  end unless method_defined? :decode_visual

  def align_left
    string = dup
    relevant_lines = string.split(/\r\n|\r|\n/).select { |line| line.size > 0 }
    indentation_levels = relevant_lines.map do |line|
      match = line.match(/^( +)[^ ]+/)
      match ? match[1].size : 0
    end
    indentation_level = indentation_levels.min
    string.gsub! /^#{' ' * indentation_level}/, '' if indentation_level > 0
    string
  end unless method_defined? :align_left

end

class NilClass
  def blank?
    true
  end
end