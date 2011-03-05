require File.join(File.dirname(__FILE__), '..', 'frases_barriales.rb')

require 'rspec'
require 'sinatra'
require 'rack/test'

# set test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false


RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end