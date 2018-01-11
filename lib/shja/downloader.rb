require 'zip'
require 'speedpetal'

class Shja::Downloader
  attr_reader :client

  def initialize(client)
    @client = client
  end

  def raw_download(from, to, ignore_error: false, unexpected_types: ['html'])
    unless file_exists?(to)
      return client.agent.download(from, to, unexpected_types)
    end
    return false
  rescue => ex
    if ignore_error
      Shja.log.error(ex.message)
      Shja.log.error(ex.backtrace.join("\n"))
      return false
    else
      raise ex
    end
  end

  def file_exists?(path)
    return File.file?(path) && (File.size(path) > 0)
  end

end

require 'shja/downloader/carib'
