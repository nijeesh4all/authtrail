require 'bundler/setup'
require 'karafka/web'

require_relative 'karafka.rb'

Bundler.require

run Karafka::Web::App
