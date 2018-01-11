require 'sinatra'
require 'sinatra/json'
require 'shja'

class Shja::Server < Sinatra::Base
  set :static, false
  set :db, Shja::Db::Carib.new(
    prefix: ENV['CARIB_ETCD_PREFIX'] || 'carib',
    endpoints: ENV['CARIB_ETCD_ENDPOINTS']
  )

  configure :production do
    require 'sinatra/xsendfile'
    helpers Sinatra::Xsendfile
    Sinatra::Xsendfile.replace_send_file!
    set :xsf_header, 'X-Accel-Redirect'
  end

  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
  end

  helpers do
    def db
      return settings.db
    end
  end

  get '/' do
    open( File.join(File.dirname(__FILE__), '..', '..', 'dist', 'index.html') ) do |io|
      io.read
    end
  end

end

require 'shja/server/carib'
