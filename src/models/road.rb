# This class contains the Road (background) functionality.
class Road
  attr_reader :speed

  def initialize(background_file)
    @image = Gosu::Image.new(background_file, tileable: true)
    @xa = @ya = @xb = 0.0
    @yb = HEIGHT * -1
    @speed = 5.0
    @speed_limit = 25.0
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
    @image.draw(@xa, @ya, ZOrder::BACKGROUND)
    @image.draw(@xb, @yb, ZOrder::BACKGROUND)
  end
end
