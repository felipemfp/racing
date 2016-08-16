class MenuState < State
  def initialize(options = {})
    super options
    @font = Gosu::Font.new(25, name: 'src/media/fonts/Play-Regular.ttf')
    @options = @main.lang.menu
    @margins = [30, 40]
    @current_option = 0
    @background = Gosu::Image.new('src/media/images/menu-bg.jpg', tileable: true)
    @option_sample = Gosu::Sample.new('src/media/sounds/menu-option.wav')
    @song = Gosu::Song.new('src/media/sounds/menu.wav')
    @main.play_sound(@song, true)
  end

  def update
  end

  def draw
    @background.draw(0, 0, ZOrder::Background)
    @options.each_with_index do |option, i|
      caption = option
      caption = '  ' + caption if i == @current_option
      top_margin = @margins[0] + (@margins[1] * i)
      @font.draw(caption, @margins[0], top_margin, ZOrder::UI)
    end
  end

  def button_down(id)
    if id == Gosu::KbReturn || id == Gosu::GpButton2
      case @current_option
      when @options.size - 1
        @main.close
      else
        @main.state = @current_option + 1
      end
    elsif id == Gosu::KbDown || id == Gosu::GpDown
      @main.play_sound(@option_sample)
      @current_option += 1
      @current_option = 0 if @current_option >= @options.size
    elsif id == Gosu::KbUp || id == Gosu::GpUp
      @main.play_sound(@option_sample)
      @current_option -= 1
      @current_option = @options.size - 1 if @current_option < 0
    elsif id == Gosu::KbEscape || id == Gosu::GpButton1
      @main.close
    end
  end
end
