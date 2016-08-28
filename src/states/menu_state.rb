# This class handles the Menu state behavior.
class MenuState < State
  def initialize(options = {})
    super options
    load_assets
    @current_option = 0
    @main.play_sound(@song, true)
  end

  def load_assets
    raise NotImplementedError, 'This is not implemented!'
  end

  def update
  end

  def draw
    @background.draw(0, 0, ZOrder::BACKGROUND)
  end

  def handle_choice
    raise NotImplementedError, 'This is not implemented!'
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
    when Gosu::KbDown, Gosu::GpDown, Gosu::KbUp, Gosu::GpUp
      handle_navigation(id)
    when Gosu::KbEscape, Gosu::GpButton1
      @main.state = 0
    end
  end
end
