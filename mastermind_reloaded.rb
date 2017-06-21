require 'sinatra'
require 'sinatra/reloader' if development?
require_relative 'peg'

configure do
  enable :sessions
end

def computer_make_code
  @code = []
  available_colors = ["blue", "green", "orange", "purple", "red", "yellow"]
  4.times do
    @code << available_colors[rand(5)]
  end
  @code
end

def computer_guess(display)
  available_colors = ["blue", "green", "orange", "purple", "red", "yellow"]

  session['pegs'].each_with_index do |peg, i|
    if display[i] == "black" #if black use for this peg again
      peg.found_color = true
    elsif display[i] == "white"
      peg.avoid << peg.color #if white use for different peg, but not this one
      session['saved'] << peg.color
    elsif display[i] == "      "
      session['avoid_all'] << peg.color #if "    " don't use for any peg
    end

    session['avoid_all'].each do |color|
      peg.avoid << color
    end

    if peg.found_color == false
      if peg.color.nil?
        peg.color = available_colors[rand(6)]
      elsif peg.avoid.include?(peg.color)
        colors = available_colors - peg.avoid
        if session['saved'] == []
          peg.color = colors[rand(colors.length)]
        elsif session['saved'].any? { |saved| colors.include?(saved) }
          peg.color = session['saved'].detect { |saved| colors.include?(saved) }
          session['saved'].delete(peg.color)
        else
          peg.color = colors[rand(colors.length)]
        end
      end
    end
  end

  guess = []
  session['pegs'].each { |peg| guess << peg.color }
  return guess
end

def compare_guess_to_code(guess, code)
  i = 0
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
    session['display'] = @display
  end
  @display
end

get '/' do
  session['pegs'] = []
  session['saved'] = []
  session['avoid_all'] = []
  4.times do
    session['pegs'] << Peg.new
  end
  session['display'] = [" ", " ", " ", " "]
  @session = session
  @message = "Would you like to play as codebreaker or codemaker?"
  erb :index
end

get '/submit' do
  session['available_colors'] = ["blue", "green", "orange", "purple", "red", "yellow"]
  @display = session['display']
  if params.has_key?('role')
    @role = params['role']
    session['role'] = params['role']
  end

  if params.has_key?('guess')
    @role = session['role']
    unless params['guess'] == 'rules'
      @guess = params['guess']
      @guess.gsub!("  ", " ")
      @guess.gsub!("  ", " ")
      @guess.gsub!(", ", " ")
      @guess.gsub!(",", " ")
      @guess.split(" ")
      session['guess'] = @guess
    end
    @guess = session['guess']
    if session['turn'] == 0
      @message = 'Type your guesses below or type "rules" for a refresher on how to play.'
    else
      @message = 'Guess again or type "rules" for a refresher on how to play.'
    end
    if params['guess'] == 'rules'
      @message = File.read("codebreaker_rules.txt")
      session['turn'] -= 1
      @guess = session['guess']
    elsif params['guess'].split(" ").all? { |guess| session['available_colors'].include?(guess) } == false
      @role = session['role']
      session['turn'] -= 1
      @message = 'Your input could not be understood. Type your guesses below or type "rules" for a refresher on how to play.'
    end

  elsif params.has_key?('code')
    @role = session['role']
    session['code'] = params['code'].split(' ')
    @code = params['code'].split(' ')
    if params['code'] == 'rules'
      @message = File.read("codemaker_rules.txt")
      session['turn'] -= 1
      session['guess'] = "none"
    elsif params['code'].split(" ").all? { |color| session['available_colors'].include?(color) } == false
      @role = session['role']
      session['turn'] -= 1
      @message = 'Your input could not be understood. Type your code below or type "rules" for a refresher on how to play.'
    else
      12.times do
        session['guess'] = computer_guess(session['display'])
        session['display'] = compare_guess_to_code(session['guess'], session['code'])
        session['turn'] += 1
        break if session['guess'] == session['code']
      end
    end
    @guess = session['guess']

  elsif @role == "codemaker"
    session['turn'] = 0
    @turn = session['turn']
    session["role"] = "codemaker"
    @message = 'Type your code below or type "rules" for a refresher on how to play.'

  elsif @role == "codebreaker"
    session['turn'] = 0
    @turn = session['turn']
    session['code'] = computer_make_code
    session['role'] = "codebreaker"
    @message = 'Type your guesses below or type "rules" for a refresher on how to play.'

  elsif params.has_key?('start')
    session.delete('code')
    session.delete('guess')
    redirect to('/')

  else
    @role = session['role']
    @message = 'Your input could not be understood. Please type either "codebreaker" or "codemaker".'
  end

  if session.has_key?('code') && session.has_key?('guess')
    session['display'] = compare_guess_to_code(session['guess'], session['code'])
    @display = session['display']
    if session['guess'] == session['code']
      @message = "Code guessed correctly!"
    end
  end

  @message = "Game over! Turns exceed 14!" if session['turn'] >= 12

  session['turn'] += 1
  @turn = session['turn']
  @session = session
  erb :index
end