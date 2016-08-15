class GameState < State
  def initialize(options = {})
    super options

    @score_font = Gosu::Font.new(15, name: 'src/media/fonts/Play-Regular.ttf')
    @gameover = Gosu::Image.from_text(
      @main.lang.data['game_over'].sample, 45, font: 'src/media/fonts/NeedforFont.ttf'
    )
    @gameover_image = Gosu::Image.new('src/media/images/gameover.png', tileable: true)

    @pause_font = Gosu::Font.new(25, name: 'src/media/fonts/Play-Regular.ttf')
    @pause_image = Gosu::Image.new('src/media/images/shade.png', tileable: true)
    @pause_options = @main.lang.pause_options
    @current_option = 0
    @margins = [30, HEIGHT - 100, 30]

    @initial_millis = Gosu.milliseconds

    @alive = true
    @paused = false

    @score = 0
    @score_label = @main.lang.score_label

    @car_brake = Gosu::Sample.new('src/media/sounds/car-brake.wav')
    @car_speed = Gosu::Song.new('src/media/sounds/car-speed.wav')

    @main.play_sound(@car_speed, true)

    @player = Player.new(CARS[@main.data['current_car']][0], CARS[@main.data['current_car']][1])
    if @player.song
      @player.sample = @main.play_sound(@player.song, true, 0.5)
    end
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

  def draw
    if @paused
      @pause_image.draw(0, 0, ZOrder::Cover)

      @pause_options.each_with_index do |option, i|
        caption = option
        caption = '  ' + caption if i == @current_option
        top_margin = @margins[1] + (@margins[2] * i)
        @pause_font.draw(caption, @margins[0], top_margin, ZOrder::UI)
      end
    end
  end

  def button_down(id)
    if !@alive
      leave_game
    else
      if id == Gosu::KbEscape || id == Gosu::GpButton1
        @paused = !@paused
      end
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
end
