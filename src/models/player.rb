# This class contains the Player properties and functionality.
class Player
  attr_reader :song, :speed, :speed_limit, :speed_minimun
  attr_accessor :score, :sample

  def initialize(animation_file, song_file, margin_left, margin_right)
    @animation = Gosu::Image.load_tiles(animation_file, 140, 140)
    @song = Gosu::Sample.new(song_file) if song_file
    @margin_left = margin_left
    @margin_right = margin_right
    load_properties
  end

  def load_properties
    @x = 0.0
    @y = 0.0
    @angle = 0.0
    @score = 0
    @speed = 1.0
    @speed_limit = 3.5
    @speed_minimun = 1.0
    @acceleration = [1.025, 0.975]
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

  def reset_angle
    @angle = 0.0
  end

  def move_left
    @angle = -5.0
    @x -= @speed * 1.25
    @x = @margin_left if @x <= @margin_left
  end

  def move_right
    @angle = 5.0
    @x += @speed * 1.25
    @x = @margin_right if @x >= @margin_right
  end

  def collision?(cars)
    cars.each do |car|
      if @x > car.x
        return true if left_collision?(car)
      elsif right_collision?(car)
        return true
      end
    end
    false
  end

  def left_collision?(car)
    return (@x - car.x < 50 && @y - car.y < 110) if @y > car.y
    (@x - car.x < 50 && car.y - @y < 110)
  end

  def right_collision?(car)
    return (car.x - @x < 50 && car.y - @y < 110) if car.y > @y
    (car.x - @x < 50 && @y - car.y < 110)
  end

  def draw
    image = @animation[Gosu.milliseconds / 100 % @animation.size]
    image.draw_rot(@x, @y, ZOrder::PLAYER, @angle)
  end
end
