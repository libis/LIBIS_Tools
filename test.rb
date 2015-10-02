require 'libis-tools'
require 'parslet'
require 'parslet/convenience'

# noinspection RubyResolve
class FieldSpecParser < Libis::Tools::Metadata::BasicParser

  root(:criteria)

  rule(:criteria) { selection >> ( spaces >> selection ).repeat }

  rule(:selection) { must >> must_not.maybe }

  rule(:must) { names.as(:must).maybe >> (one_of | only_one_of).maybe }
  rule(:must_not) { minus >> must.as(:not) }

  rule(:one_of) { lrparen >> names.as(:one_of) >> rrparen }
  rule(:only_one_of) { lcparen >> names.as(:only_one_of) >> rcparen }

  rule(:names) { (character | number).repeat(1) }

  def self.criteria_to_s(criteria)
    case criteria
      when Array
        # leave as is
      when Hash
        criteria = [criteria]
      else
        return criteria
    end
    criteria.map { |selection|  selection_to_s(selection) }.join(' ')
  end

  def self.selection_to_s(selection)
    return selection unless selection.is_a? Hash
    result = "#{selection[:must]}"
    result += "(#{selection[:one_of]})" if selection[:one_of]
    result += "{#{selection[:only_one_of]}}" if selection[:only_one_of]
    result += "-#{selection_to_s(selection[:not])}" if selection[:not]
    result
  end

end

require 'awesome_print'

def parse(string)
  tree = FieldSpecParser.new.parse_with_debug(string)
  puts "parse '#{FieldSpecParser.criteria_to_s(tree)}'"
  ap tree
end

parse ''
parse 'abc'
parse 'abc-de'
parse 'abc(de)'
parse 'abc{de}'
parse 'a(bc)-de'
parse 'a-b     c-d'
parse 'a-(bc)'
parse 'a-{bc}'
