# encoding: utf-8

class Hash

  def cleanup
    self.delete_if { |_,v| v.nil? || (v.respond_to?(:empty?) ? v.empty? : false) }
  end unless method_defined? :cleanup

  def recursive_merge(other_hash)
    self.merge(other_hash) do |_, old_val, new_val|
      if old_val.is_a? Hash
        old_val.recursive_merge new_val
      else
        new_val
      end
    end
  end unless method_defined? :recursive_merge

  def recursive_merge!(other_hash)
    self.merge!(other_hash) do |_, old_val, new_val|
      if old_val.is_a? Hash
        old_val.recursive_merge new_val
      else
        new_val
      end
    end
  end unless method_defined? :recursive_merge!

  def key_strings_to_symbols(opts = {})
    opts = {resursive: false, upcase: false, downcase: false}.merge opts

    r = Hash.new
    self.each_pair do |k,v|

      k = k.to_s if k.kind_of? Symbol
      if k.kind_of? String
        k = k.downcase if opts[:downcase]
        k = k.upcase if opts[:upcase]
        k = k.to_sym
      end

      if opts[:recursive]
        case v
          when Hash
            v = v.key_strings_to_symbols opts
          when Array
            # noinspection RubyResolve
            v = v.collect { |a| (a.kind_of? Hash) ? a.key_strings_to_symbols(opts) :  Marshal.load(Marshal.dump(a)) }
          else
            # noinspection RubyResolve
            v = Marshal.load(Marshal.dump(v))
        end
      end

      r[k] = v

    end

    r
  end unless method_defined? :key_strings_to_symbols

  def key_symbols_to_strings!(opts = {})
    self.replace self.key_symbols_to_strings opts
  end unless method_defined? :key_symbols_to_strings!

  def key_symbols_to_strings(opts = {})
    opts = {resursive: false, upcase: false, downcase: false}.merge opts

    r = Hash.new
    self.each_pair do |k,v|

      k = k.to_sym if k.kind_of? String
      if k.kind_of? Symbol
        k = k.to_s
        k = k.downcase if opts[:downcase]
        k = k.upcase if opts[:upcase]
      end

      if opts[:recursive]
        case v
          when Hash
            v = v.key_symbols_to_strings(opts)
          when Array
            # noinspection RubyResolve
            v = v.collect { |a| (a.kind_of? Hash) ? a.key_symbols_to_strings(opts) : Marshal.load(Marshal.dump(a)) }
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