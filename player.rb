class Player
  attr_reader :score

  def initialize
    @image= Gosu::Image.new('media/car.png')
    @x, @y, @angle = 0.0
    @score = 0
    @vel = 1.0
  end

  def warp(x, y)
    @x, @y = x, y
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
    if @x <= 175.0
      @x = 175.0
    end
  end

  def move_right
    @angle = 5.0
    @x += @vel
    if @x >= 335.0
      @x = 335.0
    end
  end

  def collision?(cars)
    cars.each do |car|
      if @x > car.x
        if @y > car.y
          if @x - car.x < 50 and @y - car.y < 110
            return true
          end
        else
          if @x - car.x < 50 and car.y - @y < 110
            return true
          end
        end
      else
        if car.y > @y
          if car.x - @x < 50 and car.y - @y < 110
            return true
          end
        else
          if car.x - @x < 50 and @y - car.y < 110
            return true
          end
        end
      end
    end
    return false
  end

  def draw
    @image.draw_rot(@x, @y, ZOrder::Player, @angle)
  end
end
