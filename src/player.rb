class Player
  attr_reader :score

  def initialize(animation)
    @animation = animation
    @x, @y, @angle = 0.0
    @score = 0
    @vel = 1.0
  end

  def warp(x, y)
    @x = x
    @y = y
  end

  def set_score(s)
    @score = s
  end

  def accelerate
    @vel *= 1.025
  end

  def reset_angle
    @angle = 0.0
  end

  def move_left
    @angle = -5.0
    @x -= @vel
    @x = 175.0 if @x <= 175.0
  end

  def move_right
    @angle = 5.0
    @x += @vel
    @x = 335.0 if @x >= 335.0
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
    image = @animation[Gosu::milliseconds / 100 % @animation.size]
    image.draw_rot(@x, @y, ZOrder::Player, @angle)
  end
end
