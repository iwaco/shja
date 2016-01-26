
class Shja::Movie

  def initialize(data)
    @data_hash = data
  end

  def method_missing(method_sym, *arguments, &block)
    if @data_hash.include? method_sym.to_s
      @data_hash[method_sym.to_s]
    else
      super
    end
  end

  def respond_to?(method_sym, include_private = false)
    if @data_hash.include? method_sym.to_s
      true
    else
      super
    end
  end

  def [](key)
    return @data_hash[key]
  end

  def []=(key, value)
    return @data_hash[key] = value
  end

  def <=>(other)
    if(other.kind_of?(Carib::Movie))
      return "#{self.date}-#{self.id}" <=> "#{other.date}-#{other.id}"
    else
      return nil
    end
  end

  def to_h
    @data_hash.dup
  end
end
