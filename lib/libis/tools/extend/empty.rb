# Extension for NilClass
class NilClass
  # Allows nil.empty?
  def empty?
    true
  end
end