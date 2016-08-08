class GameState
  def initialize(main)
    @main = main
    @data = JSON.parse(File.read('src/data/data.json'))

    @score_font = Gosu::Font.new(15, name: 'src/media/fonts/NeedforFont.ttf')
    @gameover = Gosu::Image.from_text(
      @data['game_over'].sample, 45, font: 'src/media/fonts/NeedforFont.ttf'
    )

    @initial_millis = Gosu.milliseconds
    @last_millis = millis
    @cars_interval = 7500

    @interval = 2

    @road = Road.new

    @player = Player.new
    @player.warp(WIDTH / 2, HEIGHT - 90)

    @car_image = [
      'src/media/images/ambulance.png',
      'src/media/images/audi.png',
      'src/media/images/audi.png',
      'src/media/images/audi.png',
      'src/media/images/black_viper.png',
      'src/media/images/black_viper.png',
      'src/media/images/mini_truck.png',
      'src/media/images/mini_truck.png',
      'src/media/images/mini_truck.png',
      'src/media/images/mini_van.png',
      'src/media/images/mini_van.png',
      'src/media/images/police.png',
      'src/media/images/taxi.png',
      'src/media/images/taxi.png',
      'src/media/images/taxi.png',
      'src/media/images/taxi.png',
      'src/media/images/taxi.png',
      'src/media/images/taxi.png'
    ]
    @cars = []

    @alive = true

    @car_brake = Gosu::Sample.new('src/media/sounds/car-brake.wav')
    @car_speed = Gosu::Song.new('src/media/sounds/car-speed.wav')

    @car_speed.play(true)
  end

  def millis
    Gosu.milliseconds - @initial_millis
  end

  def update
    if @alive
      if millis - @last_millis > @cars_interval
        @cars << Car.new(Gosu::Image.new(@car_image.sample))
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
        @car_brake.play
        @car_speed.stop
        @alive = false
        if @player.score > @data['high_scores'][-1]
          @data['high_scores'] << @player.score
          @data['high_scores'] = @data['high_scores'].sort.reverse.take(5)
          File.open('src/data/data.json', 'w') do |f|
            f.write(@data.to_json)
          end
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
