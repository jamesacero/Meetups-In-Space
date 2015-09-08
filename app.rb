require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'omniauth-github'

require_relative 'config/application'
set :environment, :development

Dir['app/**/*.rb'].each { |file| require_relative file }

helpers do
  def current_user
    user_id = session[:user_id]
    @current_user ||= User.find(user_id) if user_id.present?
  end

  def signed_in?
    current_user.present?
  end
end

def set_current_user(user)
  session[:user_id] = user.id
end

def authenticate!
  unless signed_in?
    flash[:notice] = 'You need to sign in if you want to do that!'
    redirect '/'
  end
end

get '/' do
  meetups = Meetup.all.order(name: :asc)
  erb :index, locals: {meetups: meetups}
end

get '/auth/github/callback' do
  auth = env['omniauth.auth']

  user = User.find_or_create_from_omniauth(auth)
  set_current_user(user)
  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/'
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."

  redirect '/'
end

# get '/example_protected_page' do
#   authenticate!
# end

get '/meetup/:id' do
  meetup = Meetup.find(params[:id])
  erb :show, locals: {meetup: meetup}
end

post '/meetup/:id' do
  authenticate!
  user = User.find(session[:user_id])
  meetup = Meetup.find(params[:id])
  Attendee.create(meetup: meetup, user: user)
  flash[:notice] = "You've joined this meetup!"
  redirect "/meetup/#{meetup.id}"
end


get '/create_meetup' do
  authenticate!
  erb :add_meetup
end

post '/create_meetup' do
  meetup = Meetup.create(name: params[:name], description: params[:description], location: params[:location])
  flash[:notice] = "You've created your new meetup... in space!"

  redirect "/meetup/#{meetup.id}"
end
