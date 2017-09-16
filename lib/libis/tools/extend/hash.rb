require 'backports/rails/hash'

# Extension class for Hash
class Hash

  # Removes all hash entries for which value.empty? is true
  def cleanup
    self.delete_if { |_,v| v.nil? || (v.respond_to?(:empty?) ? v.empty? : false) }
  end unless method_defined? :cleanup

  # Removes all hash entries for which value.empty? is true. Performed recursively.
  def recursive_cleanup
    delete_proc = Proc.new do |_, v|
      v.delete_if(&delete_proc) if v.kind_of?(Hash)
      v.nil? || (v.respond_to?(:empty?) ? v.empty? : false)
    end
    self.delete_if &delete_proc
  end unless method_defined? :recursive_cleanup

  # Merges two hashes, but does so recursively.
  def recursive_merge(other_hash)
    self.merge(other_hash) do |_, old_val, new_val|
      if old_val.is_a? Hash
        old_val.recursive_merge new_val
      else
        new_val
      end
    end
  end unless method_defined? :recursive_merge

  # Merges two hashes in-place, but does so recursively.
  def recursive_merge!(other_hash)
    self.merge!(other_hash) do |_, old_val, new_val|
      if old_val.is_a? Hash
        old_val.recursive_merge new_val
      else
        new_val
      end
    end
  end unless method_defined? :recursive_merge!

  # Merges two hashes with priority for the first hash
  def reverse_merge(other_hash)
    self.merge(other_hash) {|_,v, _| v}
  end unless method_defined? :reverse_merge

  # Merges two hashes in-place with priority for the first hash
  def reverse_merge!(other_hash)
    self.merge!(other_hash) {|_,v, _| v}
  end unless method_defined? :reverse_merge!

  # Convert all keys to symbols. In-place operation.
  # @param (see #key_strings_to_symbols)
  def key_strings_to_symbols!(options = {})
    self.replace self.key_strings_to_symbols options
  end unless method_defined? :key_strings_to_symbols!

  # Return new Hash with all keys converted to symbols.
  # @param [Hash] opts valid options are:
  #   * recursive : perform operation recursively
  #   * upcase : convert all keys to upper case
  #   * downcase : convert all keys to lower case
  #   all options are false by default
  def key_strings_to_symbols(options = {})
    options = {resursive: false, upcase: false, downcase: false}.merge options

    r = Hash.new
    self.each_pair do |k,v|

      k = k.to_s if k.kind_of? Symbol
      if k.kind_of? String
        k = k.downcase if options[:downcase]
        k = k.upcase if options[:upcase]
        k = k.to_sym
      end

      if options[:recursive]
        case v
          when Hash
            v = v.key_strings_to_symbols options
          when Array
            # noinspection RubyResolve
            v = v.collect { |a| (a.kind_of? Hash) ? a.key_strings_to_symbols(options) :  Marshal.load(Marshal.dump(a)) }
          else
            # noinspection RubyResolve
            v = Marshal.load(Marshal.dump(v))
        end
      end

      r[k] = v

    end

    r
  end unless method_defined? :key_strings_to_symbols

  # Convert all keys to strings. In-place operation.
  # (@see #key_symbols_to_strings)
  # @param (see #key_symbols_to_strings)
  def key_symbols_to_strings!(options = {})
    self.replace self.key_symbols_to_strings options
  end unless method_defined? :key_symbols_to_strings!

  # Return new Hash with all keys converted to strings.
  # (see #key_strings_to_symbols)
  # @param (see #key_strings_to_symbols)
  def key_symbols_to_strings(options = {})
  options = {resursive: false, upcase: false, downcase: false}.merge options

    r = Hash.new
    self.each_pair do |k,v|

      k = k.to_sym if k.kind_of? String
      if k.kind_of? Symbol
        k = k.to_s
        k = k.downcase if options[:downcase]
        k = k.upcase if options[:upcase]
      end

      if options[:recursive]
        case v
          when Hash
            v = v.key_symbols_to_strings(options)
          when Array
            # noinspection RubyResolve
            v = v.collect { |a| (a.kind_of? Hash) ? a.key_symbols_to_strings(options) : Marshal.load(Marshal.dump(a)) }
          else
            # noinspection RubyResolve
            v = Marshal.load(Marshal.dump(v))
        end
      end

      r[k] = v

    end

    r
  end unless method_defined? :key_symbols_to_strings

end