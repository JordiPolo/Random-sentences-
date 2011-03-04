require 'spec_helper'

describe "My sentences" do
  
  include Rack::Test::Methods

  def app
    @app ||= Sinatra::Application
  end

  ["/", "/todas_las_frases", "/mumimama"].each do |page|
    context "for the url #{page}" do
      it "should get some response" do
        get page
        last_response.should be_ok
      end
      
      it "should return the correct content-type" do
        get page
        last_response.headers["Content-Type"].should == "text/html;charset=utf-8"
      end
      
      it "should return some content" do
        get page
        last_response.headers["Content-Length"].to_i.should > 0
      end
    end
    
  end
  
  it "should return 404 when page cannot be found" do
    get '/404'
    last_response.status.should == 404
  end
  
    
  it "should be css in the headers when getting css" do
    pending
    get '/styles.css'
    last_response.headers["Content-Type"].should == 'text/css;charset=utf-8'
  end
  
  it "should respond to /style.css" do
    pending
    get '/styles.css'
    last_response.should be_ok
  end
  
  
  
end

