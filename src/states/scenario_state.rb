class ScenarioState < State
  def initialize(options = {})
    super options
    @current_option = @main.data['last_scenario']
    @background = Gosu::Image.new('src/media/images/scenario-bg.jpg', tileable: true)
    @select = Gosu::Image.new('src/media/images/select.png')
    @option_sample = Gosu::Sample.new('src/media/sounds/menu-option.wav')
    @song = Gosu::Song.new('src/media/sounds/menu.wav')
    @main.play_sound(@song, true)
  end

  def update
  end

  def draw
    @background.draw(0, 0, ZOrder::BACKGROUND)
    if @current_option == 1
      @select.draw(0, 0, ZOrder::COVER)
    else
      @select.draw(WIDTH / 2, 0, ZOrder::COVER)
    end
  end

  def button_down(id)
    if id == Gosu::KbReturn || id == Gosu::GpButton2
      @main.data['last_scenario'] = @current_option
      case @current_option
      when 0
        @main.state = 5
      when 1
        @main.state = 6
      end
    elsif id == Gosu::KbLeft || id == Gosu::GpLeft || id == Gosu::KbRight || id == Gosu::GpRight
      @main.play_sound(@option_sample)
      @current_option = @current_option == 0 ? 1 : 0
    elsif id == Gosu::KbEscape || id == Gosu::GpButton1
      @main.state = 0
    end
  end
end
