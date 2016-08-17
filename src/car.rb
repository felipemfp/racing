class Car
  attr_reader :x, :y, :song, :speed, :angle
  attr_accessor :sample, :stop_x

  def initialize(animation_file, song_file, player_speed, pos, angle, move)
    @animation = Gosu::Image.load_tiles(animation_file, 140, 140)
    @song = Gosu::Sample.new(song_file) if song_file
    @y = rand(100.0..170.0) * -1
    @initial_angle = angle
    @angle = @initial_angle
    @x = pos.sample
    @speed = @angle == 180.0 ? rand(7.5..8.5) + (2*player_speed) : rand(2.0..3.0) + player_speed
    @speed_limit = @angle == 180.0 ? 20.0 : 10.0
    @speed_minimun = @angle == 180.0 ? 10.0 : 2.0
    @acceleration = [1.05, 0.95]
    @stop_x = @x
    if move
      ind = pos.index(@x)
      if ind == 0
        @stop_x = pos[ind+1]
      elsif ind == pos.size - 1
        @stop_x = pos[ind-1]
      else
        @stop_x = pos[[ind-1, ind+1].sample]
      end
    end
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
    if @x != @stop_x && @y > 0
      if @stop_x > @x
        @angle = @initial_angle == 180 ? 175.0 : 5.0
        @x += @speed * 0.25
        @x = @stop_x if @stop_x < @x
      else
        @angle = @initial_angle == 180 ? 185.0 : -5.0
        @x -= @speed * 0.25
        @x = @stop_x if @stop_x > @x
      end
    end
    if @x == @stop_x
      @angle = @initial_angle
    end
  end

  def draw
    image = @animation[Gosu::milliseconds / 100 % @animation.size]
    image.draw_rot(@x, @y, ZOrder::Cars, @angle)
  end
end
