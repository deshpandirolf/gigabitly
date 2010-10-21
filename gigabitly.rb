#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'bitly'
require 'sinatra'
require 'erb'
require 'cgi'
require 'json'
require 'mechanize'

module Lookup
  def self.keywords(query)
    words = []
    words += Delicious.lookup(query)
    words
  end

  module Delicious
    BASE_URL = 'http://feeds.delicious.com/v2/json/urlinfo/blogbadge'

    def self.lookup(query)
      uri = URI.parse(BASE_URL)
      res = http_get(BASE_URL + "?hash=#{md5(normalize(query))}").body

      if hash = JSON.parse(res)
        top_five_tags = hash.first['top_tags'].sort {|a,b| b[1] <=> a[1] }.first(5).map(&:first)
      end

      top_five_tags
    end

    def self.http_get(url)
       a = Mechanize.new do |agent|
         agent.user_agent_alias = 'Mac Safari'
       end
       a.get(url)
    end

    # Do the initial follow
    # e.g. mongodb.org -> mongodb.org/
    def self.normalize(query)
      http_get(query).uri.to_s
    end

    def self.md5(query)
      Digest::MD5.hexdigest(query)
    end
  end
end

module Registration
  
  def self.init
    config_file = File.join(File.dirname(__FILE__), 'bitly.yml')
    if !File.file?(config_file)
      raise "ERROR: Must have a bitly.yml file (see bitly.yml.example)"
    end

    config = YAML.load(config_file)['bitly']
    Bitly.use_api_version_3
    @@bitly = Bitly.new(config['username'], config['api_key'])
  end

  def self.keyword_available?(keyword)
    info = @@bitly.info(keyword)
    info.error && info.error == "NOT_FOUND"
  end

  def self.register(url, short)
    @@bitly.shorten(url)
  end
end

Registration.init

get '/' do
  @title = "Gigabitly"
  @content = erb :index
  erb :base
end

post '/link' do
  @url = params["u"]
  @title = @url + " - Gigabitly"
  @shorts = Lookup.keywords(@url)
  @content = erb :link
  erb :base
end

post '/short' do
  redirect Registration.register(params["u"], :keyword => params["s"]).short_url
end
