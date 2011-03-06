#encoding: utf-8

require 'datamapper' 
require 'dm-aggregates' 


#database stuff
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/my.db")

configure :test do
  DataMapper.setup(:default, "sqlite::memory:")
end


class Sentence
  include DataMapper::Resource
  property :id, Serial
  property :contents, Text, :required => true
  property :speaker, String, :required => true
  property :meaning, String
  property :created_at, DateTime
  
  
  def self.random
    Sentence.first(:limit => 1, :offset =>rand(Sentence.count))
  end
  
  
  def self.solve_names
    Sentence.all.each do |sentence|
      if sentence.speaker == "Vic" or sentence.speaker == "Victor"
        sentence.speaker = "Víctor"
        sentence.save
      elsif sentence.speaker =="Johnny"
        sentence.speaker = "John"
        sentence.save
      elsif sentence.speaker =="Alvaro"
        sentence.speaker = "Álvaro"
        sentence.save
      end
    end
  end
  
  def self.all_speakers    
    names = Sentence.all.map {|s| s.speaker} 
    names.uniq!
    names
  end
  
  def self.ranking
    names = Sentence.all_speakers
    
    ranking ={}
    names.each do |n|
      count = Sentence.count( :speaker => n )
      ranking[n] = count
    end
    ranking = ranking.sort{|a,b| a[1] <=> b[1]}.reverse!.first(5)
    ranking
  end
  
end
# migrate deletes all the data , dangerous
Sentence.auto_migrate! unless Sentence.storage_exists?


