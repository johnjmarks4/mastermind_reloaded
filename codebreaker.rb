class Codebreaker
  attr_accessor :pegs
  
  def initialize(name)
    @name = name
    @pegs = []
    @saved = []
    @avoid_all = []
    4.times do
      @pegs << Peg.new 
    end
  end
  
  def computer_guess(display)
    available_colors = ["blue", "green", "orange", "purple", "red", "yellow"]

    @pegs.each_with_index do |peg, i|
      if display[i] == "black" #if black use for this peg again
        peg.found_color = true
      elsif display[i] == "white"
        peg.avoid << peg.color #if white use for different peg, but not this one
        @saved << peg.color
      elsif display[i] == "      "
        @avoid_all << peg.color #if "    " don't use for any peg
      end

      @avoid_all.each do |color|
        peg.avoid << color
      end

      if peg.found_color == false
        if peg.color.nil?
          peg.color = available_colors[rand(6)]
        elsif peg.avoid.include?(peg.color)
          colors = available_colors - peg.avoid
          if @saved == []
            peg.color = colors[rand(colors.length)]
          elsif @saved.any? { |saved| colors.include?(saved) }
            peg.color = @saved.detect { |saved| colors.include?(saved) }
            @saved.delete(peg.color)
          else
            peg.color = colors[rand(colors.length)]
          end
        end
      end
    end

    guess = []
    @pegs.each { |peg| guess << peg.color }
    return guess
  end
  
  def manually_guess(input)
    input.gsub!("  ", " ")
    input.gsub!("  ", " ")
    input.gsub!(", ", " ")
    input.gsub!(",", " ")
    guess = input.split(" ")
  end  
end

class Peg
  attr_accessor :avoid, :found_color, :color

  def initialize
    @avoid = []
    @found_color = false
    @color = nil
  end
end