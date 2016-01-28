
class Shja::ManagerBase
  attr_reader :db

  def initialize(db)
    @db = db
  end
end

class Shja::ResourceBase
  attr_reader :data_hash

  def initialize(data_hash)
    @data_hash = data_hash
  end

  def _download(agent, url, path)
    dir = File.dirname(path)
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    unless File.file?(path)
      agent.download(url, path)
    else
      Shja::log.debug("Skip download: #{url}")
    end
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

  def ==(other)
    return false unless other.kind_of?(Shja::ResourceBase)
    return false unless self['url']
    self['url'] == other['url']
  end

  def to_h
    @data_hash.dup
  end
end
