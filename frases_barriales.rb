#encoding: utf-8
require 'rubygems' #for datamapper
require 'sinatra'
require 'omniauth/oauth' #FB auth
require 'datamapper' 
require 'dm-aggregates' 
require 'rack-flash' # the flash[] object
require 'fb_graph' #FB API wrapper
require 'haml'

enable :sessions
use Rack::Flash 

#http://apps.facebook.com/frases_barriales/
APP_ID = "205413256141281"
APP_SECRET = "4d3679eb622a8c46293af883f640037f"

use OmniAuth::Builder do
  provider :facebook, APP_ID, APP_SECRET, { :scope => 'status_update, publish_stream, offline_access' }
end



#database stuff
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/my.db")

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
end
# migrate deletes all the data , dangerous
Sentence.auto_migrate! unless Sentence.storage_exists?


def get_sentence
      @sentence = Sentence.random 
      session["contents"] = @sentence.contents
      session["speaker"] = @sentence.speaker
#      session["meaning"] = @sentence.meaning
end


def solve_names
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

def all_speakers
  names = []
  Sentence.all.each do |s|
    names << s.speaker  
  end
  names.uniq!
end

def get_ranking
  names = all_speakers
  ranking ={}
  names.each do |n|
    count = Sentence.count( :speaker => n )
    ranking[n] = count
  end
  ranking = ranking.sort{|a,b| a[1] <=> b[1]}.reverse!.first(5)
  ranking
end

get '/' do
  get_sentence
  #raise params.to_s
  @ranking = get_ranking
  erb :index
end

#facebook calls this

post '/' do  
#  redirect "https://www.facebook.com/dialog/oauth?client_id=#{APP_ID}&redirect_uri=http://localhost:4567/auth/facebook"
  redirect to "/auth/facebook"
  get_sentence
  
  @ranking = get_ranking
  erb :index
end

#all the sentences
get '/todas_las_frases' do
  solve_names 
  @speakers = all_speakers
  @sentences = Sentence.all
  erb :all_sentences
end

# new sentence
get '/mumimama' do
  erb :new
end


get '/postToFB' do
  me = FbGraph::User.me( session['fb_token'])  
  me.feed!(
  :message => "Las frases del barrio",
  :name => "#{session['speaker']} dijo:", 
  :caption => "#{session['contents']}",
#  :from => {:name => "numbre"},
#  :caption => "",
  :link =>"http://frasesbarrio.heroku.com",
  :picture => "http://frasesbarrio.heroku.com/images/logo.jpg",
  :attribution => APP_ID
  )
  flash[:notice] = "Enviado a tu muro"
  redirect '/'
  
end


# create new task   
post '/sentences/create' do
  meaning = params[:meaning]
  if not meaning.nil?
    meaning = meaning[0..35]
  end
  sentence = Sentence.new(:contents => params[:contents], 
                          :speaker => params[:speaker],
                          :meaning => params[:meaning] )
  if sentence.save
    status 201
    flash[:notice] = "Frase creada, tenemos #{Sentence.count} frases ueueue ;)"
    redirect '/mumimama'
#    redirect '/task/'+task.id.to_s  
  else
    status 412
    flash[:notice] = "Error creando la frase ;("
    redirect '/mumimama'   
  end
end

get '/style.css' do
  scss '/style.scss'
end


get '/auth/facebook/callback' do
#  raise "auth facebook"
  session['fb_auth'] = request.env['omniauth.auth']
  session['fb_token'] = session['fb_auth']['credentials']['token']
  session['fb_error'] = nil
  redirect '/'
end

get '/auth/failure' do
  clear_session
  session['fb_error'] = 'Para que esto tire tienes que dejarme acceder a tu FB<br />'
  redirect '/'
end

get '/logout' do
  clear_session
  redirect '/'
end

def clear_session
  session['fb_auth'] = nil
  session['fb_token'] = nil
  session['fb_error'] = nil
end
