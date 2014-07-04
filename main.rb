$:.unshift "."
require 'sinatra'
require "sinatra/reloader" if development?
require 'sinatra/flash'
require 'database'
require 'auth'
require 'pp'

enable :sessions
set :session_secret, '*&(^#234)'
set :reserved_words, %w{grammar test login auth logout favicon.jpg}
set :max_files, 10        # no more than max_files+1 will be saved per user
set :max_users_shown, 8

helpers do
  def current?(path='/')
    (request.path==path || request.path==path+'/') ? 'active' : ''
  end
end

get '/grammar' do
  erb :grammar
end

get '/test' do
  erb :test
end

# Necesario, bug de Rubygems
class String
  def name
    to_str
  end
end

get '/logout' do
  # Si está autenticado, desautenticar
  if session[:auth]
    session[:auth] = nil;
    flash[:notice] = 
      %Q{<div class="notice bg-lime fg-white marker-on-top">Se ha cerrado sesion correctamente.</div>}
  end
  
  redirect "/"
end

# Raiz, sin usuario seleccionado
get '/' do
  # Truco: Hacer que los programas sean la lista actual de usuarios (o 10 aleatorios)
  # Escoger 10 usuarios aleatorios
  usuarios = User.all
  programs = []

  i = 0
  length = usuarios.length
  if usuarios.length != 0
    while i < length && i < settings.max_users_shown
      # Coger un usuario aleatorio y añadirlo a programas
      u = usuarios.sample
      programs.concat([u.username])
      usuarios.delete(u)
      i += 1
    end
  end
  
  source = "a = 3-2-1."
  erb :index, 
      :locals => { :programs => programs, :source => source, :user => "" }
end

get '/:user?/:file?' do |user, file|
  # Buscar y mostrar la lista de programas de un usuario
  u = User.first(:username => user)

  if !u
    flash[:notice] = 
      %Q{<div class="notice bg-darkRed fg-white marker-on-top">No se ha encontrado al usuario "#{user}". </div>}
    redirect to '/'
  end
  
  # Cargar programa del usuario deseado
  programs = u.pl0programs
  c = programs.first(:name => file)
  
  if !c
    flash[:notice] = 
      %Q{<div class="notice bg-darkRed fg-white marker-on-top">No se ha encontrado el fichero "#{file}" del usuario "#{user}". </div>}
    redirect to '/'
  end

  # Cargar los datos para la página
  source = c.source

  erb :index, :locals => { :programs => programs, :source => source, :user => '/' + u.username + '/' }
end

get '/:user?' do |user|    
  # Buscar programas de un usuario y mostrarlos en el menu
  u = User.first(:username => user)

  if !u
    flash[:notice] = 
      %Q{<div class="notice bg-darkRed fg-white marker-on-top">No se ha encontrado al usuario "#{user}". </div>}
    redirect to '/'
  end

  # Cargar los programas del usuario actual
  programs = u.pl0programs
  source = ""

  erb :index, :locals => { :programs => programs, :source => source, :user => u.username + '/' }
end

get '/:selected?' do |selected|
  # Buscar programas de un usuario y mostrarlos en el menu
  u = User.first(:username => selected)
  puts u
  if !u
    flash[:notice] = 
      %Q{<div class="notice bg-darkRed fg-white marker-on-top">No se ha encontrado al usuario "#{selected}". </div>}
    redirect to '/'
  end

  # Cargar los programas del usuario actual
  programs = u.pl0programs

  c = programs[0]
  source = if c then c.source else "a = 3-2-1." end
  erb :index,  :locals => { :programs => programs, :source => source, :user => u.username }
end

post '/save' do
  pp params
  name = params[:fname]
  if session[:auth] # authenticated
    if settings.reserved_words.include? name  # check it on the client side
      flash[:notice] = 
        %Q{<div class="notice bg-darkRed fg-white marker-on-top">No se puede guardar el fichero de nombre '#{name}'.</div>}
      redirect back
    else
      # Comprobar si el usuario existe.
      puts "-> " + session[:email] + " <-"
      u = User.first(:username => session[:email])
      if !u
        # Si no existe, error fatal
        # u = User.create(:username => session[:email])
        # puts "-> Creando nuevo usuario ->  " + u.to_str
        flash[:notice] = 
          %Q{<div class="notice bg-darkRed fg-white marker-on-top">No existe el usuario '#{session[:email]}' en la base de datos .</div>}
        redirect to '/'
      end
      pp u

      # Crear un programa y asociar al usuario
      c  = u.pl0programs.first(:name => name)
      if c
        c.source = params["input"]
        c.save
      else
        if Pl0program.all.size >= settings.max_files
          c = Pl0program.all.sample
          c.destroy
        end
        c = Pl0program.create(:name => params["fname"], :source => params["input"])
        
        u.pl0programs << c
      end
      
      # Guardar el usuario
      u.save
      
      flash[:notice] = 
        %Q{<div class="notice bg-cyan fg-white marker-on-top">Fichero guardado como "#{c.name}" por "#{session[:name]}".</div>}
      # redirect to '/'+name
      redirect to '/' + u.username + '/' + name 
    end
  else
    flash[:notice] = 
      %Q{<div class="notice bg-darkRed fg-white marker-on-top">No esta autenticado.<br />
         Inicie sesion con Google o con Facebook.
         </div>}
    redirect back
  end
end
