# This class handles the Options state behavior.
class OptionsState < State
  def initialize(options = {})
    super options
    load_options
    load_assets
    load_languages
    load_difficulties
    @margins = [30, 30, HEIGHT - 45, 250]
    @current_option = 0
    @current_language =
      @languages.find { |l| l[1] == @main.data['config']['language'] }
    @main.play_sound(@song, true)
  end

  def load_assets
    @back_font = Gosu::Font.new(15, name: 'src/media/fonts/Play-Regular.ttf')
    @option_font = Gosu::Font.new(20, name: 'src/media/fonts/Play-Regular.ttf')
    @background = Gosu::Image.new('src/media/images/options-bg.jpg',
                                  tileable: true)
    @option_sample = Gosu::Sample.new('src/media/sounds/menu-option.wav')
    @song = Gosu::Song.new('src/media/sounds/menu.wav')
  end

  def load_options
    @options = @main.lang['options'].push(@main.lang['option_back']).uniq
    @options_sound = @main.sound_label
    @options_countdown = @main.countdown_label
    @options_difficulty = @main.lang[@main.current_difficulty[:difficulty]]
  end

  def load_languages
    @languages = @main.lang.languages
  end

  def load_difficulties
    @difficulties = @main.data['config']['difficulty'].keys
  end

  def update
  end

  def draw
    @background.draw(0, 0, ZOrder::BACKGROUND)
    draw_options
    draw_choices
  end

  def draw_options
    @options.each_with_index do |option, i|
      caption = i == @current_option ? '  ' + option : option
      margin_top = @margins[0] + (@margins[1] * i)
      font = @option_font
      if i == @options.size - 1
        margin_top = @margins[2]
        font = @back_font
      end
      font.draw(caption, @margins[0], margin_top, ZOrder::UI)
    end
  end

  def draw_choices
    [
      @current_language[0],
      @options_sound,
      @options_difficulty,
      @options_countdown
    ].each_with_index do |caption, i|
      @option_font.draw(caption, @margins[3], @margins[0] * (i + 1), ZOrder::UI)
    end
  end

  def next_difficulty
    nxt = @difficulties.index(@main.current_difficulty[:difficulty]) + 1
    nxt = 0 if nxt == @difficulties.size
    @main.data['config']['current_difficulty'] = @difficulties[nxt]
  end

  def handle_choice
    case @current_option
    when @options.size - 1 then @main.state = 0
    when 0 then @current_language = @main.lang.switch
    when 1 then @main.toggle_music(@song, true)
    when 2 then next_difficulty
    when 3 then @main.toggle_countdown
    end
  end

  def handle_navigation(button_id)
    @main.play_sound(@option_sample)
    case button_id
    when Gosu::KbDown, Gosu::GpDown
      @current_option += 1
      @current_option = 0 if @current_option >= @options.size
    when Gosu::KbUp, Gosu::GpUp
      @current_option -= 1
      @current_option = @options.size - 1 if @current_option < 0
    end
  end

  def button_down(id)
    case id
    when Gosu::KbReturn, Gosu::GpButton2
      handle_choice
      load_options
    when Gosu::KbDown, Gosu::GpDown, Gosu::KbUp, Gosu::GpUp
      handle_navigation(id)
    when Gosu::KbEscape, Gosu::GpButton1 then @main.state = 0
    end
  end
end
