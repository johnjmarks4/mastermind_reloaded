require 'sinatra'
require 'sinatra/reloader' if development?
require_relative 'game'
require_relative 'codemaker'
require_relative 'codebreaker'

configure do
  enable :sessions
end

my_game = Game.new

def computer_make_code
  @code = []
  available_colors = ["blue", "green", "orange", "purple", "red", "yellow"]
  4.times do
    @code << available_colors[rand(5)]
  end
  @code
end

get '/' do
  session['turn'] = 0
  @turn = session['turn']
  @session = session
  @display = " "
  @message = "Would you like to play as codebreaker or codemaker?"
  erb :index
end

get '/submit' do
  @display = my_game.display
  @role = params['role']
  if @role == "codemaker"
    session["role"] = "codemaker"
    @message = 'Type your code below or type "rules" for a refresher on how to play.'
  elsif @role == "codebreaker"
    session["code"] = computer_make_code
    session["role"] = "codebreaker"
    @message = 'Type your guesses below or type "rules" for a refresher on how to play.'
  elsif @role == "rules" && session["role"] == "Codemaker"
    @message = File.read("codemaker_rules.txt")
  elsif @role == "rules" && session["role"] == "Codebreaker"
    @message = File.read("codebreaker_rules.txt")
  elsif defined?(params['code'])
    session['code'] = params['code']
    @code = params['code']
    @message = "The computer will now try to guess your code!"
  else
    @message = 'Your input could not be understood. Please type either "codebreaker" or "codemaker".'
  end

  session['turn'] += 1
  @turn = session['turn']
  @session = session
  erb :index
end