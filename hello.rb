require 'sinatra'
require "sinatra/reloader" if development?
require "sinatra/cookies"
require "sinatra/json"
require 'redis'

configure do
    if development?
      uri = URI.parse("redis://localhost:6379")
    else
      uri = URI.parse(ENV["REDISCLOUD_URL"])
    end
    $redis = Redis.new(host:     uri.host, 
                       port:     uri.port,
                       password: uri.password)
end

get '/' do
  @visitors = $redis.get( 'number_of_visitors' ).to_i
  $redis.set( 'number_of_visitors', (@visitors + 1).to_s)
  @you_seen_me = cookies[:you_seen_me]
  erb :index
end

get '/goodbye' do
  erb :goodbye
end 

post '/fire_at_will' do
  fingers = params[:fingers].to_i
  last_fingers = $redis.get('last_fingers').to_i
  $redis.set('last_fingers',fingers)
  if (fingers + last_fingers).odd? 
    @result = "you win!"
    $redis.incr("wins")
  else
    @result = "you lose!"
    $redis.incr("losses")
  end
  @wins = $redis.get('wins') || 0
  @losses = $redis.get('losses') || 0
  erb :score
end