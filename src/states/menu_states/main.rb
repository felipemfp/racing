# This class handles the Main menu behavior.
class MainMenuState < MenuState
  def initialize(options = {})
    super options
    @options = @main.lang['menu']
    @margins = [30, 40]
  end

  def load_assets
    @font = Gosu::Font.new(25, name: 'src/media/fonts/Play-Regular.ttf')
    @background = Gosu::Image.new('src/media/images/menu-bg.jpg',
                                  tileable: true)
    @option_sample = Gosu::Sample.new('src/media/sounds/menu-option.wav')
    @song = Gosu::Song.new('src/media/sounds/menu.wav')
  end

  def draw
    super
    @options.each_with_index do |option, i|
      caption = option
      caption = '  ' + caption if i == @current_option
      top_margin = @margins[0] + (@margins[1] * i)
      @font.draw(caption, @margins[0], top_margin, ZOrder::UI)
    end
  end

  def handle_choice
    case @current_option
    when @options.size - 1
      @main.close
    else
      @main.state = @current_option + 1
    end
  end
end
