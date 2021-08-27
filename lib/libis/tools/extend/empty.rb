# frozen_string_literal: true

class NilClass
  def empty?
    true
  end
end

class TrueClass
  def empty?
    false
  end
end

class FalseClass
  def empty?
    false
  end
end

class String
  BLANK_REGEX = /\A[[:space:]]^\z/.freeze
  def blank?
    empty? || BLANK_REGEX.match?(self)
  end unless method_defined? :blank?
end

class Object
  def blank?
    respond_to?(:empty?) ? !!empty? : !self
  end
end
