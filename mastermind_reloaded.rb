require 'sinatra'
require 'sinatra/reloader' if development?
require_relative 'game'
require_relative 'codemaker'
require_relative 'codebreaker'

configure do
  enable :sessions
end

my_game = Game.new

player = my_game.player
computer = my_game.computer

if player.class == Codebreaker
  code = computer.randomly_make_code
  puts 'Type your guesses below or type "rules" for a refresher on how to play.'
  puts "\n"

  while turns <= 12
    input = gets.chomp
    input.downcase!
    guess = player.manually_guess(input)

    while code.join == "rules"
      puts File.read("codebreaker_rules.txt")
      code = player.manually_make_code(gets.chomp)
    end

    until guess.all? { |color| ["red", "green", "blue", "purple", "orange", "yellow"].include?(color) }
      if guess == ["rules"]
        puts File.read("codebreaker_rules.txt")
      elsif guess.all? { |colors| ["red", "green", "blue", "purple", "orange", "yellow"].include?(colors) } == false
        puts "One of your colors was not understood. Please try again."
      end
      guess = gets.chomp.downcase
      guess = player.manually_guess(guess)
    end

    if code == guess
      puts "You won! Congrats!\n"
      print code
      break
    else
      my_game.compare_guess_to_code(guess, code)
      puts "Turn #{(turns + 1)}:\n"
      print (my_game.display).join(", ")
      puts "\n\n"
    end

    turns += 1

    if turns == 13
      puts "Your turns are up! You lose!"
      puts "Here's what the code was: #{code}"
    end
  end
end

if player.class == Codemaker

  puts 'Type your code below or type "rules" for a refresher on how to play.'
  puts "\n"
  input = gets.chomp
  input.downcase!
  code = player.manually_make_code(input)

  while code.join == "rules"
    puts File.read("codemaker_rules.txt")
    code = player.manually_make_code(gets.chomp)
  end

  while turns <= 12
    guess = computer.computer_guess(my_game.display)

    if guess == code
      puts "Oh no! The computer correctly guessed your code #{code}! You've lost!"
      break
    else
      puts "\nComputer guess number #{(turns + 1)}:\n"
      print guess
      puts "\n"
      my_game.compare_guess_to_code(guess, code)
      print [(my_game.display).join(", ")]
      puts "\n\n"
    end

    turns += 1

    if turns == 13
      puts "\nThe computer wasn't able to guess your code!"
      puts "You won!"
    end

  get '/' do
    #session["turns"] = 0
    #@session = session
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

  end
end