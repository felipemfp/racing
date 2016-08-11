class GameState < State
  def initialize(options = {})
    super options

    @score_font = Gosu::Font.new(15, name: 'src/media/fonts/Play-Regular.ttf')
    @gameover = Gosu::Image.from_text(
      @main.lang.data['game_over'].sample, 45, font: 'src/media/fonts/NeedforFont.ttf'
    )
    @gameover_image = Gosu::Image.new('src/media/images/gameover.png', tileable: true)

    @initial_millis = Gosu.milliseconds
    @last_millis = millis
    @cars_interval = 7500

    @distance = 0
    @distance_per_car = 7.5
    @distance_last_car = 0

    @cars_outdated = 0
    @cars_interval = 10
    @cars_from_now = 0

    @interval = 2
    @score_label = @main.lang.score_label

    @road = Road.new

    @player = Player.new(CARS[@main.data['current_car']][0], CARS[@main.data['current_car']][1])
    @player.warp(WIDTH / 2, HEIGHT - 90)

    @cars = []

    @alive = true

    @car_brake = Gosu::Sample.new('src/media/sounds/car-brake.wav')
    @car_speed = Gosu::Song.new('src/media/sounds/car-speed.wav')

    @main.play_sound(@car_speed, true)
    if @player.song
      @player.sample = @main.play_sound(@player.song, true, 0.5)
    end
  end

  def millis
    Gosu.milliseconds - @initial_millis
  end

  def update
    if @alive
      if @distance - @distance_per_car > @distance_last_car
        next_car = CARS.sample
        car = Car.new(next_car[0], next_car[1], @player.speed)
        if car.song
          car.sample = @main.play_sound(car.song, true, 0.3)
        end
        @cars << car
        @last_millis = millis
        @distance_last_car = @distance
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
      elsif Gosu.button_down?(Gosu::KbUp) || Gosu.button_down?(Gosu::GpUp)
        @player.accelerate
        @cars.each(&:accelerate)
        @road.accelerate
      elsif Gosu.button_down?(Gosu::KbDown) || Gosu.button_down?(Gosu::GpDown)
        @player.brake
        @cars.each(&:brake)
        @road.brake
      else
        @player.reset_angle
      end
      @road.move
      @cars.each(&:move)
      @cars.each_with_index do |car, i|
        if car.y >= 512 + 140
          car.sample.stop if car.sample
          @cars[i] = nil
          @cars_outdated += 1
        end
      end
      @cars = @cars.compact
      if @cars_outdated - @cars_from_now == @cars_interval
        @distance_per_car -= 0.5
        @cars_from_now = @cars_outdated
      end
      if @player.collision?(@cars)
        @main.play_sound(@car_brake)
        @car_speed.stop
        @alive = false
        if @player.score > @main.data['high_scores'][-1]
          @main.data['high_scores'] << @player.score
          @main.data['high_scores'] = @main.data['high_scores'].sort.reverse.take(5)
        end
        @player.sample.stop if @player.sample
      end
      @player.set_score(millis / 226)
      if millis - @last_millis > 500
        @distance += @player.speed
        @last_millis = millis
      end
    end
  end

  def draw
    @player.draw
    @road.draw
    @cars.each(&:draw)
    @score_font.draw("#{@score_label}: #{@cars_outdated}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xff_f5f5f5)
    # @score_font.draw("Velocidade: #{@player.speed}", 10, 40, ZOrder::UI, 1.0, 1.0, 0xff_f5f5f5)
    # @score_font.draw("Distance: #{@distance}", 10, 60, ZOrder::UI, 1.0, 1.0, 0xff_f5f5f5)
    # @score_font.draw("Pista: #{@road.speed}", 10, 80, ZOrder::UI, 1.0, 1.0, 0xff_f5f5f5)
    # @score_font.draw("Limite: #{@distance_per_car}", 10, 100, ZOrder::UI, 1.0, 1.0, 0xff_f5f5f5)
    # @score_font.draw("Last: #{@distance_last_car}", 10, 120, ZOrder::UI, 1.0, 1.0, 0xff_f5f5f5)
    # @score_font.draw("Ultrapassados: #{@cars_outdated}", 10, 140, ZOrder::UI, 1.0, 1.0, 0xff_f5f5f5)
    # @score_font.draw("dasdas: #{@cars_from_now}", 10, 160, ZOrder::UI, 1.0, 1.0, 0xff_f5f5f5)
    # if @cars.size > 0
    #   @score_font.draw("Carro: #{@cars[0].speed}", 10, 200, ZOrder::UI, 1.0, 1.0, 0xff_f5f5f5)
    # end
    @gameover.draw_rot(WIDTH / 2, HEIGHT / 2, ZOrder::UI, -7.0) unless @alive
    @gameover_image.draw(0, 0, ZOrder::Texture) unless @alive
  end

  def button_down(id)
    if id == Gosu::KbEscape || id == Gosu::GpButton1 || !@alive
      @car_speed.stop
      @cars.each do |car|
        car.sample.stop if car.sample
        car = nil
      end
      @cars = @cars.compact
      @player.set_score(0)
      @player.sample.stop if @player.sample
      @main.state = 0
    end
  end
end
