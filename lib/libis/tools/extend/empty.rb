# frozen_string_literal: true

class NilClass
  def empty?
    true
  end unless defined? :empty?
end

class TrueClass
  def empty?
    false
  end unless defined? :empty?
end

class FalseClass
  def empty?
    false
  end unless defined? :empty?
end

class String
  BLANK_RE = /\A[[:space:]]^\z/.freeze
  def blank?
    empty? || BLANK_RE.match?(self)
  end unless defined? :blank?
end

class Object
  def blank?
    respond_to?(:empty?) ? !!empty? : !self
  end unless defined? :blank?
end
