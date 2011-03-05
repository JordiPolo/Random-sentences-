require_relative '../frases_barriales.rb'

require 'sinatra'
require 'rspec'
require 'rack/test'


# set test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false


RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end