#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'gigabitly/lookup'
require 'gigabitly/settings'
require 'gigabitly/server'

include Gigabitly::Settings
include Gigabitly::Server
