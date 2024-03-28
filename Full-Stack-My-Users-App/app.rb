require 'sinatra'
require_relative 'my_user_model.rb'

configure do
    enable :sessions
    set :session_secret, 'super secret'
end

before do
    content_type 'application/json'
end

get '/' do
    @users = User.all
    erb :index
end

get '/users' do
    users = User.all.map { |user| user.slice("firstname", "lastname", "age", "email") }
    status 200
    users.to_json
end

post '/users' do
    if params[:firstname] && params[:lastname] && params[:age] && params[:email] && params[:password]
        new_user = User.create(params)
        status 201
        new_user.to_json
    else
        status 400
        { error: "Missing parameters" }.to_json
    end
end

post '/sign_in' do
    user = User.auth(params[:email], params[:password])
    if user
        session[:user_id] = user.id
        status 200
        user.to_json
    else
        status 401
        { error: "Invalid email or password" }.to_json
    end
end

put '/users' do
    user = User.find(session[:user_id])
    if user
        user.update(password: params[:password])
        status 200
        user.to_json
    else
        status 404
        { error: "User not found" }.to_json
    end
end

delete '/sign_out' do
    session.clear
    status 204
end

delete '/users/:id' do
    user = User.find(params[:id])
    if user
        user.destroy
        status 204
    else
        status 404
        { error: "User not found" }.to_json
    end
end

set :bind, '0.0.0.0'
set :port, 8080
