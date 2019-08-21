require 'rubygems'
require 'bundler/setup'
require 'dotenv/load'
require 'yaml'

require 'clubhouse2'

client = Clubhouse::Client.new(api_key: ENV['CLUBHOUSE_API_KEY'])
