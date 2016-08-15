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
end
