# This class contains the CPU cars functionality.
class Car
  attr_reader :x, :y, :song, :angle
  attr_accessor :sample, :stop_x, :speed

  def initialize(animation_file, song_file, angle, options = {})
    @animation = Gosu::Image.load_tiles(animation_file, 140, 140)
    @song = Gosu::Sample.new(song_file) if song_file
    @y = rand(100.0..170.0) * -1
    @initial_angle = angle
    @angle = @initial_angle
    @x = options[:pos].sample
    @stop_x = @x
    @acceleration = [1.05, 0.95]
    load_properties(options[:player_speed])
    load_movements(options[:pos], options[:move])
  end

  def load_properties(player_speed)
    if @angle == 180.0
      @speed = rand(7.5..8.5) + (2 * player_speed)
      @speed_limit = 20.0
      @speed_minimun = 10.0
    else
      @speed = rand(2.0..3.0) + player_speed
      @speed_limit = 10.0
      @speed_minimun = 2.0
    end
  end

  def load_movements(pos, move)
    return unless move
    index = pos.index(@x)
    @stop_x = if index.zero?
                pos[index + 1]
              elsif index == pos.size - 1
                pos[index - 1]
              else
                pos[[index - 1, index + 1].sample]
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

  def move
    @y += @speed
    lateral_move if @x != @stop_x && @y > 0
    @angle = @initial_angle if @x == @stop_x
  end

  def lateral_move
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

  def draw
    image = @animation[Gosu.milliseconds / 100 % @animation.size]
    image.draw_rot(@x, @y, ZOrder::CARS, @angle)
  end
end
