class Road
  attr_reader :speed
  def initialize
    @image_a = Gosu::Image.new('src/media/images/background.png', tileable: true)
    @image_b = Gosu::Image.new('src/media/images/background.png', tileable: true)
    @xa = @ya = @xb = 0.0
    @yb = HEIGHT * -1
    @speed = 5.0
    @speed_limit = 35.0
    @speed_minimun = 5.0
    @acceleration = [1.04, 0.96]
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
  
  def move
    @ya += @speed
    @yb += @speed
    @ya -= HEIGHT * 2 if @ya >= HEIGHT
    @yb -= HEIGHT * 2 if @yb >= HEIGHT
  end

  def draw
    @image_a.draw(@xa, @ya, ZOrder::Background)
    @image_b.draw(@xb, @yb, ZOrder::Background)
  end
end
