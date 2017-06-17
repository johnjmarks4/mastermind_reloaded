class Codemaker
  attr_accessor :code
  
  def initialize(name)
    @name = name
    @available_colors = ["blue", "green", "orange", "purple", "red", "yellow"]
    @code = []
  end
  
  def randomly_make_code
    4.times do
      @code << @available_colors[rand(5)]
    end
    @code
  end
  
  def manually_make_code(input)
    input = input.gsub(/,/, ", ") 
    @code = input.split(",")
    @code[0] = @code[0] + " "
    @code.map { |x| x.strip! }
    @code = input.split(" ")
    @code
  end
end