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
  BLANK_RE = /\A[[:space:]]^\z/.freeze
  def blank?
    empty? || BLANK_RE.match?(self)
  end
end

class Object
  def blank?
    respond_to?(:empty?) ? !!empty? : !self
  end
end
