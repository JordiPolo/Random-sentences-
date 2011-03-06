#encoding: utf-8

require 'sinatra'
require 'omniauth/oauth' #FB auth
require 'rack-flash' # the flash[] object
require 'fb_graph' #FB API wrapper


require './sentence' #my model

#my rack middleware to print HTTP headers and environment
#require './printout'
#use Printout

enable :sessions
use Rack::Flash # the flash[] object
use Rack::Deflater # compress all the outputs


#facebook secret information
#http://apps.facebook.com/frases_barriales/
#set up those with export APP_ID=... in a bash script
APP_ID = ENV['APP_ID']
APP_SECRET = ENV['APP_SECRET']



def get_sentence
  @sentence = Sentence.random 
  session["contents"] = @sentence.contents
  session["speaker"] = @sentence.speaker
#      session["meaning"] = @sentence.meaning
  @ranking = Sentence.ranking
  erb :index
end


get '/' do
  get_sentence    
end

#The user gets here when he comes from Facebook
post '/' do  
#  redirect "https://www.facebook.com/dialog/oauth?client_id=#{APP_ID}&redirect_uri=http://localhost:4567/auth/facebook"
  redirect to "/auth/facebook"
  get_sentence  
end


#all the sentences
get '/todas_las_frases' do
  Sentence.solve_names 
  @speakers = Sentence.all_speakers
  @sentences = Sentence.all
  erb :all_sentences
end

def logged_in?
  session['logged_in'] ||= 0
  session['logged_in'] == 1
end

# new sentence
get '/mumimama' do
  if not logged_in?
    redirect '/login'
  end
  erb :new
end

get '/login' do
  erb :login
end

post '/login' do
  if params[:name] == 'diego' && params[:password] == 'raistlin'
    
    session['logged_in'] = 1    
    flash[:notice] = "Te has autentificado"
    redirect '/mumimama'
  else
    flash[:notice] = "No puedo autentificarte"
    redirect '/login'
  end
end



get '/postToFB' do
  me = FbGraph::User.me( session['fb_token'])  
  me.feed!(
  :message => "Las frases del barrio",
  :name => "#{session['speaker']} dijo:", 
  :caption => "#{session['contents']}",
#  :description => "Aunque quiza quiso decir #{session['meaning']}",
  :link =>"http://frasesbarrio.heroku.com",
  :picture => "http://frasesbarrio.heroku.com/images/logo.jpg",
  :attribution => APP_ID
  )
  flash[:notice] = "Enviado a tu muro"
  redirect '/'
  
end


# create new task   
post '/sentences/create' do
  
  #because I created the DB with small strings, big fail
  meaning = params[:meaning]  
  meaning = meaning[0..40] unless meaning.nil?
    
  sentence = Sentence.new( :contents => params[:contents], 
                           :speaker =>  params[:speaker],
                           :meaning => params[:meaning] )
  if sentence.save
    status 201
    flash[:notice] = "Frase creada, tenemos #{Sentence.count} frases ;)"
    redirect '/mumimama'    
  else
    status 412
    flash[:notice] = "Error creando la frase ;("
    redirect '/mumimama'   
  end
end



#this gets me authenticated  with facebook
#I am getting a long time token but I am not storing it 
use OmniAuth::Builder do
  provider :facebook, APP_ID, APP_SECRET, { :scope => 'status_update, publish_stream, offline_access' }
end

#this gets called after the user got authenticated
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

get '/facebook_logout' do
  clear_session
  redirect '/'
end

def clear_session
  session['fb_auth'] = nil
  session['fb_token'] = nil
  session['fb_error'] = nil
end
