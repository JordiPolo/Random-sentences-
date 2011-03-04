require 'spec_helper'

describe "Sentences application" do
  
  include Rack::Test::Methods

  def app
    @app ||= Sinatra::Application
  end

  context "/" do
    it "should get some response" do
      get '/'
      last_response.should be_ok
    end
    
    it "should return the correct content-type" do
      get '/'
      last_response.headers["Content-Type"].should == "text/html;charset=utf-8"
    end
  end
  
  it "should return 404 when page cannot be found" do
    get '/404'
    last_response.status.should == 404
  end
  
end

