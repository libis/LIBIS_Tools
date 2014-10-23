# encoding: utf-8

class Hash

  def cleanup
    self.delete_if { |_,v| v.nil? || (v.respond_to?(:empty?) ? v.empty? : false) }
  end unless method_defined? :cleanup

end