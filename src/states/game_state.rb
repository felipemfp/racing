# This class is responsible to handle the Game state.
class GameState < State
  def initialize(options = {})
    super options
    @options = options
    load_assets
    load_properties
    load_pause_properties
    load_loading_properties
    load_player
    @speedometer = Speedometer.new
    @main.play_sound(@car_speed, true)
  end

  def load_assets
    load_fonts
    load_images
    load_sounds
    @gameover = Gosu::Image.from_text(
      @main.lang['game_over'].sample, 45, font: Path::FONTS + 'NeedforFont.ttf'
    )
    @newscore = Gosu::Image.from_text(
      @main.lang['new_score'], 45, font: Path::FONTS + 'NeedforFont.ttf'
    )
  end

  def load_fonts
    @score_font = Gosu::Font.new(15, name: Path::FONTS + 'Play-Regular.ttf')
  end

  def load_images
    @shade_image = Gosu::Image.new(Path::IMAGES + 'shade.png', tileable: true)
    @gameover_image = Gosu::Image.new(Path::IMAGES + 'gameover.png',
                                      tileable: true)
  end

  def load_sounds
    @car_brake = Gosu::Sample.new(Path::SOUNDS + 'car-brake.wav')
    @car_speed = Gosu::Song.new(Path::SOUNDS + 'car-speed.wav')
  end

  def load_properties
    @initial_millis = Gosu.milliseconds
    @last_millis = millis
    @last_acceleration = millis
    @alive = true
    @paused = false
    @loading = @main.data['config']['countdown']
    @score = 0
    @score_label = @main.lang['score_label']
    @current_wave = 0
    @cars = []
  end

  def load_pause_properties
    @pause_font = Gosu::Font.new(25, name: Path::FONTS + 'Play-Regular.ttf')
    @pause_options = @main.lang['pause_options']
    @current_option = 0
    @margins = [30, HEIGHT - 100, 30]
  end

  def load_loading_properties
    @loading_texts = @main.lang['countdown']
    @loading_index = 0
    @loading_font = Gosu::Image.from_text(
      @loading_texts[@loading_index], 90,
      font: Path::FONTS + 'NeedforFont.ttf'
    )
  end

  def load_player
    current_car = CARS[@main.data['current_car']]
    @player = Player.new(current_car[0], current_car[1],
                         @options[:player_margin_left],
                         @options[:player_margin_right])
    @player.sample = @main.play_sound(@player.song, true, 0.5) if @player.song
    @player.warp(WIDTH / 2, HEIGHT - 90)
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

  def next_car
    car = CARS.sample
    angle_index = rand(@options[:cars_angle].size)
    pos = possible_positions(angle_index)
    Car.new(car[0], car[1], @options[:cars_angle][angle_index],
            player_speed: @player.speed, pos: pos,
            move: [false, @options[:cars_move]].sample)
  end

  def possible_positions(angle_index)
    @options[:cars_pos][angle_index * 2..angle_index * 2 + 1]
  end

  def safe_to_add_new_car?(new_car)
    @cars.empty? || (
     new_car.x != @cars[-1].x &&
     new_car.stop_x != @cars[-1].x &&
     new_car.x != @cars[-1].stop_x
    )
  end

  def add_new_car
    new_car = next_car
    if safe_to_add_new_car?(new_car)
      new_car.stop_x = new_car.x if
        !@cars.empty? && new_car.stop_x == @cars[-1].stop_x
      new_car.sample = @main.play_sound(new_car.song, true, 0.3) if
        new_car.song
      @cars << new_car
      @current_wave += 1
    end
  end

  def update_cars
    return unless
      @distance - @distance_per_car > @distance_last_car ||
      @current_wave < @options[:cars_wave]

    if @current_wave < @options[:cars_wave]
      add_new_car
      @last_millis = millis
      @distance_last_car = @distance
    else
      @current_wave = 0
    end
  end

  def update_movements
    if millis / 1000 > @interval
      @road.accelerate
      @player.accelerate
      @cars.each(&:accelerate)
      @cars_interval -= 250 if @cars_interval > 1500
      @interval *= 1.2
    end
    @road.move
    @cars.each(&:move)
  end

  def handle_controls
    handle_steering
    if Gosu.button_down?(Gosu::KbUp) || Gosu.button_down?(Gosu::GpButton2)
      handle_accelerating
    elsif Gosu.button_down?(Gosu::KbDown) || Gosu.button_down?(Gosu::GpButton3)
      handle_braking
    end
  end

  def handle_steering
    if Gosu.button_down?(Gosu::KbLeft) || Gosu.button_down?(Gosu::GpLeft)
      @player.move_left
    elsif Gosu.button_down?(Gosu::KbRight) || Gosu.button_down?(Gosu::GpRight)
      @player.move_right
    else
      @player.reset_angle
    end
  end

  def handle_accelerating
    return unless millis - @last_acceleration > 100
    @player.accelerate
    @cars.each(&:accelerate)
    @road.accelerate
    @last_acceleration = millis
  end

  def handle_braking
    return unless millis - @last_acceleration > 25
    @player.brake
    @cars.each(&:brake)
    @road.brake
    @last_acceleration = millis
  end

  def handle_collision
    @main.play_sound(@car_brake)
    @car_speed.stop
    @alive = false
    @player.sample.stop if @player.sample
    handle_new_score
  end

  def handle_new_score
    high_scores = @main.data['high_scores']
    return if @player.score <= high_scores[-1]
    high_scores.push(@player.score)
    @main.data['high_scores'] = high_scores.sort.reverse.take(5)
  end

  def update_score
    @score += ((millis / @options[:score_factor] * @player.speed) / 1000)
    @score = @score.to_f.round(2)
    @player.score = @score.to_i
  end

  def handle_progression
    if millis - @last_millis > 500
      @distance += @player.speed
      @last_millis = millis
    end
  end

  def update_when_on_game
    update_cars
    update_movements
    handle_controls
    update_score
    handle_collision if @player.collision?(@cars)
    handle_progression
  end

  def update
    return if !@alive || @paused
    if !@loading
      update_when_on_game
    else
      @road.move
    end
  end

  def draw
    @player.draw
    @road.draw
    @cars.each(&:draw)
    @score_font.draw("#{@score_label}: #{@player.score}", 10, 10,
                     ZOrder::UI, 1.0, 1.0, 0xff_f5f5f5)
    @speedometer.draw(@player)
    draw_when_dead
    draw_when_pause
    draw_when_loading
  end

  def draw_when_dead
    return if @alive
    if @main.data['high_scores'][0] == @player.score
      @newscore.draw_rot(WIDTH / 2, HEIGHT / 2, ZOrder::UI, -7.0)
    elsif !@alive
      @gameover.draw_rot(WIDTH / 2, HEIGHT / 2, ZOrder::UI, -7.0)
    end
    @gameover_image.draw(0, 0, ZOrder::COVER)
  end

  def draw_when_pause
    return unless @paused
    @shade_image.draw(0, 0, ZOrder::COVER)
    @pause_options.each_with_index do |option, i|
      caption = option
      caption = '  ' + caption if i == @current_option
      top_margin = @margins[1] + (@margins[2] * i)
      @pause_font.draw(caption, @margins[0], top_margin, ZOrder::UI)
    end
  end

  def draw_when_loading
    return unless @loading
    @shade_image.draw(0, 0, ZOrder::COVER)
    @loading_font.draw_rot(WIDTH / 2, HEIGHT / 2, ZOrder::UI, 0.0)
    if @loading_index < @loading_texts.size
      handle_countdown unless @paused
    else
      @initial_millis = Gosu.milliseconds
      @loading = false
    end
  end

  def handle_countdown
    return unless millis / 1000 > 0
    @loading_index += 1
    @initial_millis = Gosu.milliseconds
    @loading_font = Gosu::Image.from_text(
      @loading_texts[@loading_index], 90,
      font: Path::FONTS + 'NeedforFont.ttf'
    )
  end

  def button_down(id)
    leave_game unless @alive
    if id == Gosu::KbEscape || id == Gosu::GpButton1
      @paused = !@paused
    elsif @paused
      handle_pause(id)
    end
  end

  def handle_pause(button_id)
    case button_id
    when Gosu::KbDown, Gosu::GpDown, Gosu::KbUp, Gosu::GpUp
      handle_navigation(button_id)
    when Gosu::KbReturn, Gosu::GpButton2
      handle_choice
    end
  end

  def handle_navigation(button_id)
    case button_id
    when Gosu::KbDown, Gosu::GpDown
      @current_option += 1
      @current_option = 0 if @current_option >= @pause_options.size
    when Gosu::KbUp, Gosu::GpUp
      @current_option -= 1
      @current_option = @pause_options.size - 1 if @current_option < 0
    end
  end

  def handle_choice
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
