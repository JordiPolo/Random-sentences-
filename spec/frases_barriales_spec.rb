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
  it "/mumimama should show a form" do
    get "/mumimama"
    last_response.body.include? "<input"
  end
  
  it "should show Hall of infame in the main page" do
    get "/"
    last_response.body.include? "Hall of"
  end
  
end



describe "Sentence" do

  
  before(:each) do
    DataMapper.auto_migrate! 
    Sentence.new(:contents => "ahora vuelco", 
                 :speaker =>"chechu", :meaning=>"ahora vuelvo").save!                 
    Sentence.new(:contents => "ahora vuelco", 
                 :speaker =>"chechu", :meaning=>"ahora vuelvo").save!                 
    Sentence.new(:contents => "ahora vuelco", 
                 :speaker =>"chechu", :meaning=>"ahora vuelvo").save!                 
    Sentence.new(:contents => "ahora vuelco", 
                 :speaker =>"miguel", :meaning=>"ahora vuelvo").save!                 
                
  end

  it "should get a valid sentence" do
    s = Sentence.random
    s.should_not be nil
  end

  it "should get all the speakers" do
    s = Sentence.all_speakers
    s.should have( 2 ).speakers    
  end
  
  it "should get the correct speakers" do
    s = Sentence.all_speakers
    s.include?("chechu").should == true
    s.include?("miguel").should == true
    
  end
  
  it "should not have more than 5 speakers in the rank" do
    r = Sentence.ranking
    r.count.should be < 6    
  end
  
  it "should speaker with most sentences be on top" do
    r = Sentence.ranking 
    r[0][0].should == "chechu"
  end
  
end

