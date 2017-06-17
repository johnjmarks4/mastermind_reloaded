class Game
  attr_accessor :display, :player, :computer
  
  def initialize(game_name, player_name)
    @game_name = game_name
    @player_name = player_name
    @display = [" ", " ", " ", " "]
  end
  
  def assign_role(choice)
    choice.downcase!

    if choice == "codemaker"
      @computer = Codebreaker.new(name="The computer")
      @player = Codemaker.new(name=@player_name) #last value is returned
    end

    if choice == "codebreaker"
      @computer = Codemaker.new(name="The computer")
      @player = Codebreaker.new(name=@player_name) #last value is returned
    end
  end
  
  def compare_guess_to_code(guess, code)
    i = 0
    while i < display.length
      if code[i] == guess[i]
        @display[i] = "black"
      elsif code.include?(guess[i])
        @display[i] = "white"
      else
        @display[i] = "      "
      end
      i += 1
    end
  end
  
  def winner?(codebreaker, codemaker)
    if codebreaker.guess == codemaker.code
      return true 
    end
  end
end