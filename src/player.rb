class Player
  attr_reader :score, :song, :speed
  attr_accessor :sample

  def initialize(animation_file, song_file, margin_left, margin_right)
    @animation = Gosu::Image.load_tiles(animation_file, 140, 140)
    @song = Gosu::Sample.new(song_file) if song_file
    @x, @y, @angle = 0.0, 0.0, 0.0
    @score = 0
    @speed = 1.0
    @speed_limit = 3.5
    @speed_minimun = 1.0
    @acceleration = [1.025,0.975]
    @margin_left = margin_left
    @margin_right = margin_right
  end

  def warp(x, y)
    @x = x
    @y = y
  end

  def set_score(s)
    @score = s
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
    @x -= @speed
    @x = @margin_left if @x <= @margin_left
  end

  def move_right
    @angle = 5.0
    @x += @speed
    @x = @margin_right if @x >= @margin_right
  end

  def collision?(cars)
    cars.each do |car|
      if @x > car.x
        if @y > car.y
          return true if @x - car.x < 50 && @y - car.y < 110
        else
          return true if @x - car.x < 50 && car.y - @y < 110
        end
      else
        if car.y > @y
          return true if car.x - @x < 50 && car.y - @y < 110
        else
          return true if car.x - @x < 50 && @y - car.y < 110
        end
      end
    end
    false
  end

  def draw
    image = @animation[Gosu.milliseconds / 100 % @animation.size]
    image.draw_rot(@x, @y, ZOrder::Player, @angle)
  end
end
