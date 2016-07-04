class Road
  def initialize
    @image_a = Gosu::Image.new('media/background.png', :tileable => true)
    @image_b = Gosu::Image.new('media/background.png', :tileable => true)
    @xa = @ya = @xb = 0.0
    @yb = HEIGHT * -1
    @vel = 5.0
  end

  def accelerate
    @vel *= 1.04
  end

  def move
    @ya += @vel
    @yb += @vel
    if @ya >= HEIGHT
      @ya -= HEIGHT * 2
    end
    if @yb >= HEIGHT
      @yb -= HEIGHT * 2
    end
  end

  def draw
    @image_a.draw(@xa, @ya, ZOrder::Background)
    @image_b.draw(@xb, @yb, ZOrder::Background)
  end
end
