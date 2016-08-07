class MenuState
  def initialize(main)
    @main = main
    @options = [
      [Gosu::Font.new(20), 'Start (press enter)', 10, 10],
      [Gosu::Font.new(20), 'Quit (press esc)', 10, 40]
    ]
  end

  def update
  end

  def draw
    @options.each_with_index do |option, i|
      option[0].draw(option[1], option[2], option[3], ZOrder::UI)
    end
  end

  def button_down(id)
    @main.state = 1 if id == Gosu::KbReturn
    @main.close if id == Gosu::KbEscape
  end
end
