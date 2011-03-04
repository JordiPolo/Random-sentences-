require 'spec_helper'

set :environment, :test

describe "My sentences" do
  
  include Rack::Test::Methods

  def app
    @app ||= Sinatra::Application
  end
  
  @HTML_PAGES = ["/", "/todas_las_frases", "/mumimama"]
  @CSS_STYLES = ["/style.css"]
  @ALL_PAGES = @HTML_PAGES + @CSS_STYLES
  
  #tests for every single valid URL
  @ALL_PAGES.each do |page|
    context "for the url #{page}" do
      it "should get some response" do
        get page
        last_response.should be_ok
      end
      
      it "should return some content" do
        get page
        last_response.headers["Content-Length"].to_i.should > 0
      end
    end
    
  end
  
  
  #Test for all the invalid URLs
  it "should return 404 when page cannot be found" do
    get '/404'
    last_response.status.should == 404
  end

  #Test for all the HTML
        
  @HTML_PAGES.each do |page|
    it "should return the correct content-type" do
      get page
      last_response.headers["Content-Type"].should == "text/html;charset=utf-8"
    end
  end
  
  @CSS_STYLES.each do |page|
    it "should return the correct content-type" do
      get page
      last_response.headers["Content-Type"].should == 'text/css;charset=utf-8'
    end
  end  
  
  
end

