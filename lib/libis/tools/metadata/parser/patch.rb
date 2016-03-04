# New style parsers and converters for metadata. New, not finished and untested.
class Parslet::Pattern

  def element_match_hash(tree, exp, bindings)
    return false if exp.size < tree.size
    exp.each do |expected_key, expected_value|
      if expected_key.to_s =~ /^(.*)\?$/
        expected_key = expected_key.is_a?(Symbol) ? $1.to_sym : $1
        return true unless tree.has_key? expected_key
      end

      return false unless tree.has_key? expected_key

      # Recurse into the value and stop early on failure
      value = tree[expected_key]
      return false unless element_match(value, expected_value, bindings)
    end

    true
  end

end