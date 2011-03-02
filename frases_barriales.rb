require 'rubygems' #for datamapper
require 'sinatra'
require 'omniauth/oauth' #FB
require 'datamapper' 
require 'rack-flash' # the flash[] object

enable :sessions
use Rack::Flash 

#http://apps.facebook.com/frases_barriales/
APP_ID = "205413256141281"
APP_SECRET = "4d3679eb622a8c46293af883f640037f"

use OmniAuth::Builder do
  provider :facebook, APP_ID, APP_SECRET, { :scope => 'status_update, publish_stream' }
end



#database stuff
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/my.db")

class Sentence
    include DataMapper::Resource
    property :id, Serial
    property :contents, Text
    property :speaker, String
    property :created_at, DateTime
    
    def self.random
      Sentence.first(:limit => 1, :offset =>rand(Sentence.count))      
    end
end
# automatically create the post table
Sentence.auto_migrate! unless Sentence.storage_exists?

post '/' do
    @sentence = Sentence.random 
    erb :index
end


get '/' do
    @sentence = Sentence.random 
    erb :index
end

# new task
get '/mumimama' do
  erb :new
end


# create new task   
post '/sentences/create' do
  sentence = Sentence.new(:contents => params[:contents], :speaker => params[:who])
  if sentence.save
    status 201
    flash[:notice] = "Nueva frase creada y almacenada ;)"
    redirect '/mumimama'
#    redirect '/task/'+task.id.to_s  
  else
    status 412
    flash[:notice] = "Error creando la frase ;("
    redirect '/mumimama'   
  end
end





get '/auth/facebook/callback' do
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
