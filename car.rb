class Car
  attr_reader :x, :y

  def initialize (image)
    pos = [180.0, 255.0, 330.0]
    @image= image
    @x, @y = pos[rand(pos.size)], rand(100.0..170.0) * -1
    @angle = 0.0
    @vel = 2.5
  end

  def warp(x, y)
    @x, @y = x, y
  end

  def accelerate
    @vel *= 1.05
  end

  def move
    @y += @vel
  end

  def draw
    @image.draw_rot(@x, @y, ZOrder::Cars, @angle)
  end
end
