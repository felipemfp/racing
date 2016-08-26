class GameState < State
  def initialize(options = {})
    super options
    @options = options

    @score_font = Gosu::Font.new(15, name: 'src/media/fonts/Play-Regular.ttf')
    @gameover = Gosu::Image.from_text(
      @main.lang.data['game_over'].sample, 45, font: 'src/media/fonts/NeedforFont.ttf'
    )
    @gameover_image = Gosu::Image.new('src/media/images/gameover.png', tileable: true)
    @newscore = Gosu::Image.from_text(
      @main.lang.data['new_score'], 45, font: 'src/media/fonts/NeedforFont.ttf'
    )

    @shade_image = Gosu::Image.new('src/media/images/shade.png', tileable: true)
    @pause_font = Gosu::Font.new(25, name: 'src/media/fonts/Play-Regular.ttf')
    @pause_options = @main.lang.pause_options
    @current_option = 0
    @margins = [30, HEIGHT - 100, 30]

    @initial_millis = Gosu.milliseconds
    @last_millis = millis
    @last_acceleration = millis

    @alive = true
    @paused = false

    @loading = @main.data['config']['countdown']
    @loading_index = 0
    @loading_texts = @main.lang.countdown
    @loading_font = Gosu::Image.from_text(
      @loading_texts[@loading_index], 90, font: 'src/media/fonts/NeedforFont.ttf'
    )

    @score = 0
    @score_label = @main.lang.score_label

    @car_brake = Gosu::Sample.new('src/media/sounds/car-brake.wav')
    @car_speed = Gosu::Song.new('src/media/sounds/car-speed.wav')

    @speedometer = Gosu::Image.new('src/media/images/speedometer.png')
    @speedometer_pointer = Gosu::Image.new('src/media/images/speedometer-pointer.png')

    @main.play_sound(@car_speed, true)

    @player = Player.new(
      CARS[@main.data['current_car']][0],
      CARS[@main.data['current_car']][1],
      @options[:player_margin_left],
      @options[:player_margin_right]
    )
    @player.sample = @main.play_sound(@player.song, true, 0.5) if @player.song

    @player.warp(WIDTH / 2, HEIGHT - 90)

    @current_wave = 0
    @cars = []
  end

  def millis
    Gosu.milliseconds - @initial_millis
  end

  def stop_sounds
    @car_speed.stop
    @cars.each do |car|
      car.sample.stop if car.sample
    end
    @player.sample.stop if @player.sample
  end

  def leave_game
    stop_sounds
    @main.state = 0
  end

  def get_next_car
    next_car = CARS.sample
    if @options[:cars_angle].size == 1
      car = Car.new(
        next_car[0],
        next_car[1],
        @options[:cars_angle][0],
        player_speed: @player.speed,
        pos: @options[:cars_pos],
        move: [false, @options[:cars_move]].sample
      )
    else
      next_angle = rand(@options[:cars_angle].size)
      next_pos = @options[:cars_pos][next_angle * 2..next_angle * 2 + 1]
      car = Car.new(
        next_car[0],
        next_car[1],
        @options[:cars_angle][next_angle],
        player_speed: @player.speed,
        pos: next_pos,
        move: [false, @options[:cars_move]].sample
      )
    end
    car
  end

  def update
    if @alive
      unless @paused
        if !@loading
          if @distance - @distance_per_car > @distance_last_car || @current_wave < @options[:cars_wave]
            if @current_wave < @options[:cars_wave]
              next_car = get_next_car
              if @cars.size.zero? || (next_car.x != @cars[-1].x && next_car.stop_x != @cars[-1].x && next_car.x != @cars[-1].stop_x)
                if !@cars.empty? && next_car.stop_x == @cars[-1].stop_x
                  next_car.stop_x = next_car.x
                end
                if next_car.song
                  next_car.sample = @main.play_sound(next_car.song, true, 0.3)
                end
                @cars << next_car
                @current_wave += 1
              end
              @last_millis = millis
              @distance_last_car = @distance
            elsif @current_wave == @options[:cars_wave]
              @current_wave = 0
            end
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

          if Gosu.button_down?(Gosu::KbUp) || Gosu.button_down?(Gosu::GpButton2)
            if millis - @last_acceleration > 100
              @player.accelerate
              @cars.each(&:accelerate)
              @road.accelerate
              @last_acceleration = millis
            end
          elsif Gosu.button_down?(Gosu::KbDown) || Gosu.button_down?(Gosu::GpButton3)
            if millis - @last_acceleration > 25
              @player.brake
              @cars.each(&:brake)
              @road.brake
              @last_acceleration = millis
            end
          end

          @road.move
          @cars.each(&:move)

          @score += ((millis / @options[:score_factor] * @player.speed) / 1000)
          @score = @score.to_f.round(2)
          @player.score = @score.to_i

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

          if millis - @last_millis > 500
            @distance += @player.speed
            @last_millis = millis
          end
        else
          @road.move
        end
      end
    end
  end

  def draw
    @player.draw
    @road.draw
    @cars.each(&:draw)
    @score_font.draw("#{@score_label}: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xff_f5f5f5)
    if @main.data['high_scores'].index(@player.score) == 0 && !@alive
      @newscore.draw_rot(WIDTH / 2, HEIGHT / 2, ZOrder::UI, -7.0)
    elsif !@alive
      @gameover.draw_rot(WIDTH / 2, HEIGHT / 2, ZOrder::UI, -7.0)
    end
    @gameover_image.draw(0, 0, ZOrder::COVER) unless @alive
    @speedometer.draw_rot(WIDTH - 80, HEIGHT - 80, ZOrder::ELEMENT, 0.0)
    @speedometer_pointer.draw_rot(WIDTH - 80, HEIGHT - 80, ZOrder::ELEMENT, speedometer_angle)
    if @paused
      @shade_image.draw(0, 0, ZOrder::COVER)
      @pause_options.each_with_index do |option, i|
        caption = option
        caption = '  ' + caption if i == @current_option
        top_margin = @margins[1] + (@margins[2] * i)
        @pause_font.draw(caption, @margins[0], top_margin, ZOrder::UI)
      end
    elsif @loading
      @shade_image.draw(0, 0, ZOrder::COVER)
      @loading_font.draw_rot(WIDTH / 2, HEIGHT / 2, ZOrder::UI, 0.0)
      if millis / 1000 > 0
        @loading_index += 1
        @initial_millis = Gosu.milliseconds
        @loading_font = Gosu::Image.from_text(@loading_texts[@loading_index], 90, font: 'src/media/fonts/NeedforFont.ttf')
      end
      if @loading_index == @loading_texts.size
        @initial_millis = Gosu.milliseconds
        @loading = false
      end
    end
  end

  def button_down(id)
    if !@alive
      leave_game
    else
      @paused = !@paused if id == Gosu::KbEscape || id == Gosu::GpButton1
      if @paused
        if id == Gosu::KbDown || id == Gosu::GpDown
          @current_option += 1
          @current_option = 0 if @current_option >= @pause_options.size
        elsif id == Gosu::KbUp || id == Gosu::GpUp
          @current_option -= 1
          @current_option = @pause_options.size - 1 if @current_option < 0
        elsif id == Gosu::KbReturn || id == Gosu::GpButton2
          case @current_option
          when @pause_options.size - 1
            leave_game
          when 1
            stop_sounds
            @main.restart
          else
            @paused = false
          end
        end
      end
    end
  end

  def speedometer_angle
    oldrange = 3.5 - 1.0
    newrange = 75 - -90
    ((@player.speed - 1.0) * newrange) / oldrange + -90
  end
end
