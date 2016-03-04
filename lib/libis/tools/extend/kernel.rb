# Extension class
module Kernel

  # Debugging aid: extract the name of the argument of the last caller
  def extract_argstring_from(name, call_stack)
    file, line_number = call_stack.first.match(/^(.+):(\d+)/).captures
    line = File.readlines(file)[line_number.to_i - 1].strip
    argstring = line[/#{name}\s*\(?(.+?)\)?\s*($|#|\[|\})/, 1]
    raise "unable to extract name for #{name} from #{file} line #{line_number}:\n  #{line}" unless argstring
    argstring
  end

  # Debugging aid: print "<name> : <value>"
  #
  # Example:
  #     x = 'abc'
  #     dputs x
  #     # => x : 'abc'
  #
  def dputs(value)
    name = extract_argstring_from :dputs, caller
    puts "#{name} : '#{value}'"
  end

end
