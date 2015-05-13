require 'libis/tools/extend/ostruct'

class DeepStruct < OpenStruct

  def initialize(data = nil)
    @table = {}

    case data
      when Hash, Set
        data.each { |key, value| self[key] = value }
      else
        self[nil] = data
    end
  end

  def initialize_copy(orig)
    super
    @table.each { |key, value| self[key] = value }
  end

  def []=(key, value)
    super(key.to_sym, case value
                        when Hash, Set
                          self.class.new(value)
                        when Array
                          value.map do |v|
                            case v
                              when Hash, Set
                                self.class.new(v)
                              else
                                v.dup
                            end
                          end
                        else
                          value.dup
                      end)
  end

  def method_missing(mid, *args) # :nodoc:
    mname = mid.id2name
    len = args.length
    if mname.chomp!('=')
      if len != 1
        raise ArgumentError, "wrong number of arguments (#{len} for 1)", caller(1)
      end
      new_ostruct_member(mname)
      self[mid] = args[0]
    elsif len == 0
      self[mid]
    else
      err = NoMethodError.new "undefined method `#{mid}' for #{self}", mid, args
      err.set_backtrace caller(1)
      raise err
    end
  end

  def to_h
    @table.each_with_object(Hash.new) do |entry, hash|
      hash[entry.first] = case entry.last
                            when self.class
                              entry.last.to_h
                            when Array
                              entry.last.map do |v|
                                v.respond_to? :to_h ? v.to_h : v
                              end
                            else
                              v.respond_to? :to_h ? v.to_h : v
                          end
    end
  end

  protected

  def new_ostruct_member(name)
    name = name.to_sym
    unless respond_to?(name)
      define_singleton_method(name) { self[name] }
      define_singleton_method("#{name}=") { |x| self[name] = x }
    end
    name
  end

end
