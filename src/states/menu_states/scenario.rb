# This class handles the Scenario menu behavior.
class ScenarioMenuState < MenuState
  def initialize(options = {})
    super options
    @current_option = @main.data['last_scenario']
  end

  def load_assets
    @background = Gosu::Image.new(Path::IMAGES + 'scenario-bg.jpg',
                                  tileable: true)
    @select = Gosu::Image.new(Path::IMAGES + 'select.png')
    @option_sample = Gosu::Sample.new(Path::SOUNDS + 'menu-option.wav')
    @song = Gosu::Song.new(Path::SOUNDS + 'menu.wav')
  end

  def draw
    super
    @select.draw(@current_option == 1 ? 0 : WIDTH / 2, 0, ZOrder::COVER)
  end

  def handle_choice
    @main.data['last_scenario'] = @current_option
    case @current_option
    when 0
      @main.state = 5
    when 1
      @main.state = 6
    end
  end

  def handle_navigation
    @main.play_sound(@option_sample)
    @current_option =
      if @current_option.zero?
        1
      else
        0
      end
  end

  def button_down(id)
    case id
    when Gosu::KbReturn, Gosu::GpButton2
      handle_choice
    when Gosu::KbLeft, Gosu::GpLeft, Gosu::KbRight, Gosu::GpRight
      handle_navigation
    when Gosu::KbEscape, Gosu::GpButton1
      @main.state = 0
    end
  end
end
