#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'sinatra'

Dir.glob('gigabitly/*.rb').each do |f|
  require f
end

include Gigabitly::Settings
include Gigabitly::Server
