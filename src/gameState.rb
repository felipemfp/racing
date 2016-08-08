class GameState < State
  def initialize(options = {})
    super options

    @score_font = Gosu::Font.new(15, name: 'src/media/fonts/NeedforFont.ttf')
    @gameover = Gosu::Image.from_text(
      @main.data['game_over'].sample, 45, font: 'src/media/fonts/NeedforFont.ttf'
    )
    @gameover_image = Gosu::Image.new('src/media/images/gameover.png', tileable: true)

    @initial_millis = Gosu.milliseconds
    @last_millis = millis
    @cars_interval = 7500

    @interval = 2

    @road = Road.new

    @player = Player.new(Gosu::Image::load_tiles(CARS[@main.data['current_car']], 140, 140))
    @player.warp(WIDTH / 2, HEIGHT - 90)

    @cars = []

    @alive = true

    @car_brake = Gosu::Sample.new('src/media/sounds/car-brake.wav')
    @car_speed = Gosu::Song.new('src/media/sounds/car-speed.wav')

    @main.play_sound(@car_speed, true)
  end

  def millis
    Gosu.milliseconds - @initial_millis
  end

  def update
    if @alive
      if millis - @last_millis > @cars_interval
        @cars << Car.new(Gosu::Image::load_tiles(CARS.sample, 140, 140))
        @last_millis = millis
      end
      if millis / 1000 > @interval
        @road.accelerate
        @player.accelerate
        @cars.each(&:accelerate)
        @cars_interval -= 250 if @cars_interval > 1500
        @interval *= 1.2
      end
      if Gosu.button_down?(Gosu::KbLeft) || Gosu.button_down?(Gosu::GpLeft)
        @player.move_left
      elsif Gosu.button_down?(Gosu::KbRight) || Gosu.button_down?(Gosu::GpRight)
        @player.move_right
      else
        @player.reset_angle
      end
      @road.move
      @cars.each(&:move)
      @cars.each do |car|
        car = nil if car.y >= 512 + 140
      end
      @cars = @cars.compact
      if @player.collision?(@cars)
        @main.play_sound(@car_brake)
        @car_speed.stop
        @alive = false
        if @player.score > @main.data['high_scores'][-1]
          @main.data['high_scores'] << @player.score
          @main.data['high_scores'] = @main.data['high_scores'].sort.reverse.take(5)
        end
      end
      @player.set_score(millis / 226)
    end
  end

  def draw
    @player.draw
    @road.draw
    @cars.each(&:draw)
    @score_font.draw("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xff_f5f5f5)
    @gameover.draw_rot(WIDTH / 2, HEIGHT / 2, ZOrder::UI, -7.0) unless @alive
    @gameover_image.draw(0, 0, ZOrder::Texture) unless @alive
  end

  def button_down(id)
    if id == Gosu::KbEscape || id == Gosu::GpButton1 || !@alive
      @car_speed.stop
      @cars.each do |_car|
        car = nil
      end
      @cars = @cars.compact
      @player.set_score(0)
      @main.state = 0
    end
  end
end
