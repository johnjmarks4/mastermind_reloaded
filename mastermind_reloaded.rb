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
=begin
def compare_guess_to_code(guess, code)
  i = 0
  while i < @display.length
    if code[i] == guess[i]
      @display[i] = "black"
    elsif code.include?(guess[i])
      @display[i] = "white"
    else
      @display[i] = "      "
    end
    i += 1
    session['display'] = @display
  end
end
=end

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
  if defined?(session['role']) == false
    @role = params['role']
    session['role'] = params['role']
  else
    @role = session['role']
  end
  if defined?(params['guess']) && @role == 'codebreaker'
    session['guess'] = params['guess']
    @guess = params['guess']
    session['turn'] == 0 ? @message = "Guess!" : @message = "Guess again!"
  elsif defined?(params['code']) && @role == 'codemaker'
    session['code'] = params['code']
    @code = params['code']
    @message = "The computer will now try to guess your code!"
  elsif @role == "codemaker"
    session["role"] = "codemaker"
    @message = 'Type your code below or type "rules" for a refresher on how to play.'
  elsif @role == "codebreaker"
    session["code"] = computer_make_code
    session["role"] = "codebreaker"
    @message = 'Type your guesses below or type "rules" for a refresher on how to play.'
  elsif @role == "rules" && session["role"] == "codemaker"
    @message = File.read("codemaker_rules.txt")
  elsif @role == "rules" && session["role"] == "codebreaker"
    @message = File.read("codebreaker_rules.txt")
  else
    @message = 'Your input could not be understood. Please type either "codebreaker" or "codemaker".'
  end

  #if defined?(@code) && defined?(@guess)
    #compare_guess_to_code(@code, @guess)
  #end

  session['turn'] += 1
  @turn = session['turn']
  @session = session
  erb :index
end