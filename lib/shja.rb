require "shja/version"
require 'logger'
require 'fileutils'

module Shja
  # Your code goes here...
  @@log = nil

  def self.log=(log)
    @@log = log
  end

  def self.log
    unless @@log
      @@log = Logger.new(STDERR)
    end
    @@log
  end
end

require 'shja/db'
require 'shja/movie'
require 'shja/parser'
require 'shja/agent'
require 'shja/client'
require 'shja/downloader'
