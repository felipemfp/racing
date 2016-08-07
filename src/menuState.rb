class MenuState
  def initialize(main)
    @main = main
    @options = [
      [Gosu::Font.new(50), 'Start', 10, 10],
      [Gosu::Font.new(50), 'Quit', 10, 70]
    ]
    @current_option = 0
    @background = Gosu::Image.new('src/media/images/menu-bg.jpg', tileable: true)
    @song = Gosu::Song.new('src/media/sounds/menu.wav')
    @song.play(true)
  end

  def update
  end

  def draw
    @background.draw(0, 0, ZOrder::Background)
    @options.each_with_index do |option, i|
      caption = option[1]
      caption += ' (enter)' if i == @current_option
      option[0].draw(caption, option[2], option[3], ZOrder::UI)
    end
  end

  def button_down(id)
    if id == Gosu::KbReturn || id == Gosu::GpButton2
      case @current_option
      when 0
        @main.state = 1
      when 1
        @main.close
      end
    elsif id == Gosu::KbDown || id == Gosu::GpDown
      @current_option += 1
      @current_option = 0 if @current_option >= @options.size
    elsif id == Gosu::KbUp || id == Gosu::GpUp
      @current_option -= 1
      @current_option = @options.size - 1 if @current_option < 0
    elsif id == Gosu::KbEscape || id == Gosu::GpButton1
      @main.close
    end
  end
end
