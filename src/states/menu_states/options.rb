# This class handles the Options menu behavior.
class OptionsMenuState < MenuState
  def initialize(options = {})
    super options
    load_options
    load_languages
    load_difficulties
    @margins = [30, 30, HEIGHT - 45, 250]
    @current_language =
      @languages.find { |l| l[1] == @main.data['config']['language'] }
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

  def draw
    super
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

  def button_down(id)
    super id
    load_options if id == Gosu::KbReturn || id == Gosu::GpButton2
  end
end
