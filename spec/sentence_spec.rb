require 'spec_helper'


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

