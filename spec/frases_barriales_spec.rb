require 'spec_helper'


describe "The pages" do

  before(:each) do
    DataMapper.auto_migrate! 
    Sentence.new(:id=>1, :contents => "ahora vuelco", 
                 :speaker =>"chechu", :meaning=>"ahora vuelvo").save!                 
  end

  def app
    @app ||= Sinatra::Application  
  end
  
  @HTML_PAGES = ["/", "/todas_las_frases"]
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
    
  #Test for all the HTML      
  @HTML_PAGES.each do |page|
    context "for the url #{page}" do
      it "should return the correct content-type" do
        get page
        last_response.headers["Content-Type"].should == "text/html;charset=utf-8"
      end
    end
  end
  
  
  @CSS_STYLES.each do |page|
    context "for the url #{page}" do
      it "should return the correct content-type" do
        get page
        last_response.headers["Content-Type"].should == 'text/css;charset=utf-8'
      end
    end
  end  
  
  
  
  #Test for all the invalid URLs
  it "should return 404 when page cannot be found" do
    get '/404'
    last_response.status.should == 404
  end

    #tests for particular URLs
  it "should show Hall of infame in the main page" do
    get "/"
    last_response.body.include? "Hall of"
  end
  
  it "/mumimama should redirect to /login when not logged in" do
    #authorize "diego", "raistlin"
    get "/mumimama"
    follow_redirect!
    puts last_request.url
    last_request.url.should include "login"  
    last_response.should be_ok
  end
  
  it "/login should show a ask for name and password" do
    get "/login"
    last_response.body.include? "Nombre"
    last_response.body.include? "Password"
  end
  
  it "/mumimama should show a ask for sentence and speaker" do
    get "/login"
    last_response.body.include? "frase"
    last_response.body.include? "perpetrador"
  end
  
  it "The correct password should log in the user" do
    post "/login", :name => "diego", :password =>"raistlin"
    follow_redirect!
    last_request.session['logged_in'].should == 1 
  end
  
  it "Incorrect password should not log in the user" do
    post "/login", :name => "minga", :password =>"raistlin"
    follow_redirect!    
    last_request.session['logged_in'].should_not == 1        
  end
  
  
  it "The correct password should redirect to new sentence" do
    post "/login", :name => "diego", :password =>"raistlin"
    follow_redirect!
    last_request.url.should include "mumimama"  
    last_response.should be_ok
  end
  
  it "incorrect password should redirect to log in" do
    post "/login", :name => "minga", :password =>"raistlin"
    follow_redirect!
    last_request.url.should include "login"  
    last_response.should be_ok    
  end
  
  
end

