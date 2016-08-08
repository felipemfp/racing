class GarageState < State
  def initialize(options={})
    super options
    @option_font = Gosu::Font.new(15, name: 'src/media/fonts/NeedforFont.ttf')
    @options = [
      ['Regular Car', 30, 30],
      ['Ambulance', 30, 60],
      ['Audi', 30, 90],
      ['Black Viper', 30, 120],
      ['Mini Truck', 30, 150],
      ['Mini Van', 30, 180],
      ['Police', 30, 210],
      ['Taxi', 30, 240],
      ['Back', 30, HEIGHT - 45]
    ]
    @current_option = @main.data['current_car']
    @background = Gosu::Image.new('src/media/images/garage-bg.jpg', tileable: true)
    @option_sample = Gosu::Sample.new('src/media/sounds/menu-option.wav')
    @song = Gosu::Song.new('src/media/sounds/menu.wav')
    @main.play_sound(@song, true)
    @car = Gosu::Image::load_tiles(CARS[@main.data['current_car']], 140, 140)
    @car_font = Gosu::Font.new(20, name: 'src/media/fonts/NeedforFont.ttf')
  end

  def update
  end

  def draw
    @background.draw(0, 0, ZOrder::Background)
    @options.each_with_index do |option, i|
      caption = option[0]
      caption = '  ' + caption if i == @current_option
      if i == @options.size - 1
        @option_font.draw(caption, option[1], option[2], ZOrder::UI)
      else
        @car_font.draw(caption, option[1], option[2], ZOrder::UI)
      end
    end
    image = @car[Gosu::milliseconds / 100 % @car.size]
    image.draw_rot(355, 155, ZOrder::Cars, 0.0)
  end

  def button_down(id)
    if id == Gosu::KbReturn || id == Gosu::GpButton2
      case @current_option
      when @options.size - 1
        @main.state = 0
      else
        @main.data['current_car'] = @current_option
        @car = Gosu::Image::load_tiles(CARS[@main.data['current_car']], 140, 140)
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
end
