# This class handles the Garage menu behavior.
class GarageMenuState < MenuState
  def initialize(options = {})
    super options
    load_options
    @margins = [30, 30, HEIGHT - 45]
  end

  def load_options
    @options = @main.lang['cars_option'].push(@main.lang['option_back']).uniq
    @current_option = @main.data['current_car']
    @car = Gosu::Image.load_tiles(CARS[@current_option][0], 140, 140)
  end

  def load_assets
    @option_font = Gosu::Font.new(15, name: 'src/media/fonts/Play-Regular.ttf')
    @background = Gosu::Image.new('src/media/images/garage-bg.jpg',
                                  tileable: true)
    @option_sample = Gosu::Sample.new('src/media/sounds/menu-option.wav')
    @song = Gosu::Song.new('src/media/sounds/menu.wav')
    @car_font = Gosu::Font.new(20, name: 'src/media/fonts/Play-Regular.ttf')
  end

  def draw
    super
    draw_options
    draw_car
  end

  def draw_car
    image = @car[Gosu.milliseconds / 100 % @car.size]
    image.draw_rot(355, 155, ZOrder::CARS, 0.0)
  end

  def draw_options
    @options.each_with_index do |option, i|
      caption = i == @current_option ? '  ' + option : option
      font = @car_font
      margin_top = @margins[0] + (@margins[1] * i)
      if i == @options.size - 1
        margin_top = @margins[2]
        font = @option_font
      end
      font.draw(caption, @margins[0], margin_top, ZOrder::UI)
    end
  end

  def handle_choice
    case @current_option
    when @options.size - 1
      @main.state = 0
    else
      @car = Gosu::Image.load_tiles(CARS[@current_option][0], 140, 140)
      @main.data['current_car'] = @current_option
    end
  end
end
