require 'omniauth-oauth2'
require 'omniauth-google-oauth2'
require 'omniauth-facebook'

use OmniAuth::Builder do # 
  config = YAML.load_file 'config/config.yml' # YAML = parecido a JSON, pero con sangrado significativo. Representacion de informacion en forma textual.
  provider :google_oauth2, config['identifier'], config['secret'], :scope => "userinfo.email,userinfo.profile", :provider_ignores_state => true
  
  config = YAML.load_file 'config/configF.yml'
  provider :facebook, config['identifier'], config['secret']
end

get '/auth/:name/callback' do
  session[:auth] = @auth = request.env['omniauth.auth']
  session[:name] = @auth['info'].name
  session[:image] = @auth['info'].image
  session[:url] = @auth['info'].urls.values[0]
  session[:email] = @auth['info'].email
  
  puts "params = #{params}"
  puts "@auth.class = #{@auth.class}"
  puts "@auth info = #{@auth['info']}"
  puts "@auth info class = #{@auth['info'].class}"
  puts "@auth info name = #{@auth['info'].name}"
  puts "@auth info email = #{@auth['info'].email}"
  puts "-------------@auth----------------------------------"
  puts "*************@auth.methods*****************"
  PP.pp @auth.methods.sort
  flash[:notice] = 
        %Q{<div class="notice bg-lime fg-white marker-on-top">Autenticado como #{@auth['info'].name}.</div>}
  
  # Añadir a la base de datos directamente, siempre y cuando no exista
  if !User.first(:username => session[:email])
    u = User.create(:username => session[:email])
    u.save
  end
        
  redirect '/'
end

get '/auth/failure' do
  flash[:notice] = 
        %Q{<div class="notice bg-darkRed fg-white marker-on-top">Error: #{params[:message]}.</div>}
  redirect '/'
end
