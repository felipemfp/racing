class Car
  attr_reader :x, :y, :song, :speed, :angle
  attr_accessor :sample

  def initialize(animation_file, song_file, player_speed, pos, inverted)
    @animation = Gosu::Image.load_tiles(animation_file, 140, 140)
    @song = Gosu::Sample.new(song_file) if song_file
    @y = rand(100.0..170.0) * -1
    if inverted
      @angle = [0.0, 180.0].sample
      @x = @angle == 180.0 ? pos[0..1].sample : pos[2..3].sample
    else
      @angle = 0.0
      @x = pos.sample
    end
    @speed = (@angle == 180.0 ? rand(7.5..8.5) + (2*player_speed) : rand(2.0..3.0) + player_speed)
    @speed_limit = @angle == 180.0 ? 20.0 : 10.0
    @speed_minimun = @angle == 180.0 ? 10.0 : 2.0
    @acceleration = [1.05, 0.95]
  end

  def warp(x, y)
    @x = x
    @y = y
  end

  def accelerate
    if @speed > @speed_limit
      @speed = @speed_limit
    else
      @speed *= @acceleration[0]
    end
  end

  def brake
    if @speed < @speed_minimun
      @speed = @speed_minimun
    else
      @speed *= @acceleration[1]
    end
  end

  def set_speed(speed)
    @speed = speed
  end

  def move
    @y += @speed
  end

  def draw
    image = @animation[Gosu::milliseconds / 100 % @animation.size]
    image.draw_rot(@x, @y, ZOrder::Cars, @angle)
  end
end
