require 'sinatra'
require 'sinatra/reloader' if development?
require_relative 'game'
require_relative 'codemaker'
require_relative 'codebreaker'

configure do
  enable :sessions
end

my_game = Game.new

get '/' do
  @display = " "
  @message = "Would you like to play as codebreaker or codemaker?"
  erb :index
end

get '/submit' do
  #put display code here
  @display = my_game.display
  role = params['role']
  if role == "codemaker"
    session["role"] = "Codemaker"
    @session = session
    @message = 'Type your code below or type "rules" for a refresher on how to play.'
  elsif role == "codebreaker"
    session["role"] = "Codebreaker"
    @session = session
    @message = 'Type your guesses below or type "rules" for a refresher on how to play.'
  elsif role == "rules" && session["role"] == "Codemaker"
    @message = File.read("codemaker_rules.txt")
  elsif role == "rules" && session["role"] == "Codebreaker"
    @message = File.read("codebreaker_rules.txt")
  else
    @message = 'Your input could not be understood. Please type either "codebreaker" or "codemaker".'
  end

  erb :index
end