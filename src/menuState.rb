class MenuState
  def initialize(main)
    @main = main
    @font = Gosu::Font.new(25, name: 'src/media/fonts/NeedforFont.ttf')
    @options = [
      ['Start', 30, 30],
      ['High Scores', 30, 70],
      [@main.get_sound_label, 30, 110],
      ['Quit', 30, 150]
    ]
    @current_option = 0
    @background = Gosu::Image.new('src/media/images/menu-bg.jpg', tileable: true)
    @option_sample = Gosu::Sample.new('src/media/sounds/menu-option.wav')
    # @song = Gosu::Song.new('src/media/sounds/menu.wav')
    # @song.play(true)
    # @main.toggle_sound(@song)
  end

  def update
  end

  def draw
    @background.draw(0, 0, ZOrder::Background)
    @options.each_with_index do |option, i|
      caption = option[0]
      caption = '  ' + caption if i == @current_option
      @font.draw(caption, option[1], option[2], ZOrder::UI)
    end
  end

  def button_down(id)
    if id == Gosu::KbReturn || id == Gosu::GpButton2
      case @current_option
      when 0
        @main.state = 1
      when 1
        @main.state = 2
      when 2
        @main.toggle_music
        @options[2][0] = @main.get_sound_label
      when 3
        @main.close
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
