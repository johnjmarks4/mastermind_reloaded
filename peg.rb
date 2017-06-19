class Peg
  attr_accessor :avoid, :found_color, :color

  def initialize
    @avoid = []
    @found_color = false
    @color = nil
  end
end