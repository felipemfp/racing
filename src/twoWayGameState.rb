class TwoWayGameState < GameState
  def initialize(options = {})
    super options

    @last_millis = millis
    @cars_interval = 7500

    @distance = 0
    @distance_per_car = 7.5
    @distance_last_car = 0

    @cars_outdated = 0
    @cars_interval = 10
    @cars_from_now = 0
    @car_hit_distance = 145

    @interval = 2
    @road = Road.new('src/media/images/background-two.png')

    @player.warp(WIDTH / 2 + 70, HEIGHT - 90)

    @cars = []
    @last_car = nil
  end

  def update
    if @alive
      if !@paused
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
        else
          @player.reset_angle
        end

        if Gosu.button_down?(Gosu::KbUp) || Gosu.button_down?(Gosu::GpUp)
          @player.accelerate
          @cars.each(&:accelerate)
          @road.accelerate
        elsif Gosu.button_down?(Gosu::KbDown) || Gosu.button_down?(Gosu::GpDown)
          @player.brake
          @cars.each(&:brake)
          @road.brake
        end

        @road.move
        @cars.each(&:move)
        @last_car = nil

        @cars.reject! {|car|
          reject = false
          if car.y >= 512 + 140
            car.sample.stop if car.sample
            @cars_outdated += 1
            reject = true
          end
          @last_car = car if @last_car == nil || @last_car.y < car.y + @car_hit_distance
          reject
        }

        if @cars.size > 1 && @last_car != nil
          @cars.each_with_index do |car, i|
            @cars[i].set_speed(@last_car.speed) if @last_car.x == car.x && @last_car.y < car.y + @car_hit_distance
          end
          @last_car = nil
        end

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

        @score += (millis / 226 * @player.speed) / 1000
        @score = @score.to_f.round(2)
        @player.set_score(@score)

        if millis - @last_millis > 500
          @distance += @player.speed
          @last_millis = millis
        end
      end
    end
  end

  def draw
    @player.draw
    @road.draw
    @cars.each(&:draw)
    @score_font.draw("#{@score_label}: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xff_f5f5f5)
    @gameover.draw_rot(WIDTH / 2, HEIGHT / 2, ZOrder::UI, -7.0) unless @alive
    @gameover_image.draw(0, 0, ZOrder::Cover) unless @alive
    @pause_text.draw_rot(WIDTH / 2, HEIGHT / 2, ZOrder::UI, -7.0) if @paused
    @pause_image.draw(0, 0, ZOrder::Cover) if @paused
  end

  def button_down(id)
    if id == Gosu::KbEscape || id == Gosu::GpButton1 || !@alive
      @main.state = 0
    elsif id == Gosu::KbP
      @paused = !@paused
    end
  end
end
