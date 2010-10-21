#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'erb'

get '/' do
  @title = "Gigabitly"
  @content = erb :index
  erb :base
end

post '/link' do
  @title = params["url"] + " - Gigabitly"
  @content = erb :link
  erb :base
end

post '/shorten' do
end

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
        hash = JSON.parse(res)
        top_five_tags = hash.first['top_tags'].sort {|a,b| b[1] <=> a[1] }.first(5).map(&:first)
      end
      top_five_tags
    end

    def self.http_get(domain, path, params)
      return Net::HTTP.get(domain, "#{path}?".concat(params.collect { |k,v| "#{k}=#{CGI::escape(v.to_s)}" }.join('&'))) if not params.nil?
      return Net::HTTP.get(domain, path)
    end

    def self.md5(query)
      Digest::MD5.hexdigest(query)
    end
  end
end
