require File.join(File.dirname(__FILE__), '..', 'frases_barriales.rb')

require 'rubygems'
require 'sinatra'
require 'rack/test'

# set test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

