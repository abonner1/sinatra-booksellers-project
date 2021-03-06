require 'rack-flash'

class UsersController < ApplicationController
  use Rack::Flash

  get '/signup' do
    if logged_in?
      redirect to '/books'
    else
      erb :'/users/signup'
    end
  end

  post '/signup' do
    user = User.new(params[:user])
    if user.save
      session[:user_id] = user.id
      redirect to '/books'
    else
      flash[:error] = user.errors.full_messages.join(', ')
      redirect to '/signup'
    end
  end

  get '/login' do
    if logged_in?
      redirect '/books'
    else
      erb :'/users/login'
    end
  end

  post '/login' do
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect to '/books'
    else
      flash[:error] = "Invalid login. Either your username or password is incorrect!"
      redirect to '/login'
    end
  end

  get '/users/:slug' do
    @user = User.find_by_slug(params[:slug])
    if @user && @user == current_user
      erb :'/users/show_user'
    else
      redirect to '/login'
    end
  end

  get '/users/:slug/edit' do
    @user = User.find_by_slug(params[:slug])
    if @user && @user == current_user
      erb :'/users/edit_user'
    else
      redirect to '/login'
    end
  end

  patch '/users/:slug' do
    user = User.find_by_slug(params[:slug])
    if user.authenticate(params[:password])
      user.update(params[:user])
      redirect to "/users/#{user.slug}"
    else
      redirect to "/users/#{user.slug}/edit"
    end
  end

  get '/logout' do
    if logged_in?
      session.clear
      redirect '/login'
    else
      redirect '/'
    end
  end
end
