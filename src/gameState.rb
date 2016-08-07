class GameState
  def initialize(main)
    @main = main

    @score_font = Gosu::Font.new(20)
    @gameover = Gosu::Image.from_text(
      self, 'GAME OVER', Gosu.default_font_name, 45
    )

    @last_millis = 0
    @cars_interval = 7500

    @interval = 2

    @road = Road.new

    @player = Player.new
    @player.warp(WIDTH / 2, HEIGHT - 90)

    @car_image = [
      Gosu::Image.new('src/media/images/ambulance.png'),
      Gosu::Image.new('src/media/images/audi.png'),
      Gosu::Image.new('src/media/images/black_viper.png'),
      Gosu::Image.new('src/media/images/mini_truck.png'),
      Gosu::Image.new('src/media/images/mini_van.png'),
      Gosu::Image.new('src/media/images/taxi.png'),
      Gosu::Image.new('src/media/images/police.png')
    ]
    @cars = []

    @alive = true

    @car_brake = Gosu::Sample.new('src/media/sounds/car-brake.wav')
    @car_speed = Gosu::Song.new('src/media/sounds/car-speed.wav')

    @car_speed.play(true)
  end

  def update
    if @alive
      if Gosu.milliseconds - @last_millis > @cars_interval
        @cars << Car.new(@car_image[rand(@car_image.size)])
        @last_millis = Gosu.milliseconds
        end
      if Gosu.milliseconds / 1000 > @interval
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
        @car_brake.play
        @car_speed.stop
        @alive = false
      end
      @player.set_score(Gosu.milliseconds / 226)
    end
  end

  def draw
    @player.draw
    @road.draw
    @cars.each(&:draw)
    @score_font.draw("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xff_f5f5f5)
    @gameover.draw_rot(WIDTH / 2, HEIGHT / 2, ZOrder::UI, 0.0) unless @alive
  end

  def button_down(id)
    if id == Gosu::KbEscape
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
