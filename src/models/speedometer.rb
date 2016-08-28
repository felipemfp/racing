class Speedometer
  MAX_ANGLE = 75
  MIN_ANGLE = -90

  def initialize
    @speedometer = Gosu::Image.new(Path::IMAGES + 'speedometer.png')
    @speedometer_pointer =
      Gosu::Image.new(Path::IMAGES + 'speedometer-pointer.png')
    @x = WIDTH - 80
    @y = HEIGHT - 80
  end

  def angle(player)
    old_range = player.speed_limit - player.speed_minimun
    new_range = MAX_ANGLE - MIN_ANGLE
    ((player.speed - player.speed_minimun) * new_range) / old_range + MIN_ANGLE
  end

  def draw(player)
    @speedometer.draw_rot(@x, @y, ZOrder::ELEMENT, 0.0)
    @speedometer_pointer.draw_rot(@x, @y, ZOrder::ELEMENT, angle(player))
  end
end
