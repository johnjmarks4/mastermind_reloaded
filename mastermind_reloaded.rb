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

def compare_guess_to_code(guess, code)
  i = 0
  guess = guess.split(' ')
  @display = session['display']
  @display.each_with_index do |_, i|
    if code[i] == guess[i]
      @display[i] = "black"
    elsif code.include?(guess[i])
      @display[i] = "white"
    else
      @display[i] = "      "
    end
    i += 1
  end
  @display
end

get '/' do
  session['display'] = [" ", " ", " ", " "]
  session['turn'] = 0
  @turn = session['turn']
  @session = session
  @message = "Would you like to play as codebreaker or codemaker?"
  erb :index
end

get '/submit' do
  @display = session['display']
  if defined?(params['role'])
    @role = params['role']
    session['role'] = params['role']
  end
  if params.has_key?('guess')
    session['guess'] = params['guess']
    @guess = params['guess']
    session['turn'] == 0 ? @message = "Guess!" : @message = "Guess again!"
  elsif params.has_key?('code')
    session['code'] = params['code']
    @code = params['code']
    @message = "The computer will now try to guess your code!"
  elsif @role == "codemaker"
    session["role"] = "codemaker"
    @message = 'Type your code below or type "rules" for a refresher on how to play.'
  elsif @role == "codebreaker"
    session['code'] = computer_make_code
    session['role'] = "codebreaker"
    @message = 'Type your guesses below or type "rules" for a refresher on how to play.'
  elsif @role == "rules" && session['role'] == "codemaker"
    @message = File.read("codemaker_rules.txt")
  elsif @role == "rules" && session['role'] == "codebreaker"
    @message = File.read("codebreaker_rules.txt")
  else
    @message = 'Your input could not be understood. Please type either "codebreaker" or "codemaker".'
  end

  if session.has_key?('code') && session.has_key?('guess') #fix this
    session['display'] = compare_guess_to_code(session['guess'], session['code'])
    @display = session['display']
  end

  session['turn'] += 1
  @turn = session['turn']
  @session = session
  erb :index
end