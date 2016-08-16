class OptionsState < State
  def initialize(options = {})
    super options
    @back_font = Gosu::Font.new(15, name: 'src/media/fonts/Play-Regular.ttf')
    @option_font = Gosu::Font.new(20, name: 'src/media/fonts/Play-Regular.ttf')
    load_options
    @languages = @main.lang.get_all
    @current_language = @languages.find { |l| l[1] == @main.data['config']['language'] }
    @margins = [30, 30, HEIGHT - 45, 200]
    @current_option = 0
    @background = Gosu::Image.new('src/media/images/options-bg.jpg', tileable: true)
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
      if i == @options.size - 1
        top_margin = @margins[2]
        @back_font.draw(caption, @margins[0], top_margin, ZOrder::UI)
      else
        top_margin = @margins[0] + (@margins[1] * i)
        @option_font.draw(caption, @margins[0], top_margin, ZOrder::UI)
      end
    end
    @option_font.draw(@current_language[0], @margins[3], @margins[0], ZOrder::UI)
    @option_font.draw(@options_sound, @margins[3], @margins[0] * 2, ZOrder::UI)
  end

  def button_down(id)
    if id == Gosu::KbReturn || id == Gosu::GpButton2
      case @current_option
      when @options.size - 1
        @main.state = 0
      when 0
        @current_language = @main.lang.switch
        load_options
      when 1
        @main.toggle_music(@song, true)
        load_options
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
      @main.state = 0
    end
  end

  def load_options
    @options = @main.lang.options
    @options.push(@main.lang.back) if @options[@options.size - 1] != @main.lang.back
    @options_sound = @main.get_sound_label
  end
end
