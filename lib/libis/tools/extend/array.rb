
# Extension class for Array
class Array

  # Removes all empty entries
  def cleanup
    self.delete_if { |v| v.nil? || (v.respond_to?(:empty?) ? v.empty? : false) }
  end unless method_defined? :cleanup

  # Removes all empty entries recursively in the array and each Hash in it
  def recursive_cleanup
    each { |v| v.recursive_cleanup if Array === v || Hash === v }
    cleanup
  end unless method_defined? :recursive_cleanup

end