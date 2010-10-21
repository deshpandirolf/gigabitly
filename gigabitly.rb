#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'bitly'
require 'sinatra'
require 'erb'
require 'cgi'
require 'json'

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
      res = http_get(uri.host, uri.request_uri, :hash => md5(query))

      if res
        if hash = JSON.parse(res)
          top_five_tags = hash.first['top_tags'].sort {|a,b| b[1] <=> a[1] }.first(5).map(&:first)
        end
      end

      top_five_tags
    end

    def self.http_get(domain, path, params)
      if params
        return Net::HTTP.get(domain, "#{path}?".concat(params.collect { |k,v| "#{k}=#{CGI::escape(v.to_s)}" }.join('&')))
      end

      return Net::HTTP.get(domain, path)
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
  url = params["u"]
  short = params["s"]
  return "url " + url + " short " + short
end

