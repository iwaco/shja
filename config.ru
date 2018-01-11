$:.unshift(File.dirname(__FILE__) + '/lib')

require 'shja/server'

use Rack::Static, urls: ["/js", "/images"], root: "dist"

run Shja::Server
