class Car
  attr_reader :x, :y, :song, :speed, :angle
  attr_accessor :sample

  def initialize(animation_file, song_file, player_speed, pos, inverted, move=false)
    @animation = Gosu::Image.load_tiles(animation_file, 140, 140)
    @song = Gosu::Sample.new(song_file) if song_file
    @y = rand(100.0..170.0) * -1
    if inverted
      @angle = [0.0, 180.0].sample
      @x = @angle == 180.0 ? pos[0..1].sample : pos[2..3].sample
    else
      @angle = 0.0
      @x = pos.sample
    end
    @speed = (@angle == 180.0 ? rand(7.5..8.5) + (2*player_speed) : rand(2.0..3.0) + player_speed)
    @speed_limit = @angle == 180.0 ? 20.0 : 10.0
    @speed_minimun = @angle == 180.0 ? 10.0 : 2.0
    @acceleration = [1.05, 0.95]
    @move = move
    @last_millis = Gosu::milliseconds
    @interval = 1
    @stop_x = x
    if @move
      if inverted
        case @x
        when pos[0]
          @stop_x = pos[1]
        when pos[1]
          @stop_x = pos[0]
        when pos[2]
          @stop_x = pos[3]
        when pos[3]
          @stop_x = pos[2]
        end
      else
        case @x
        when pos[0]
          @stop_x = pos[1]
        when pos[1]
          @stop_x = pos[[0,2].sample]
        when pos[2]
          @stop_x = pos[1]
        end
      end
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

  def set_speed(speed)
    @speed = speed
  end

  def move
    @y += @speed
    if @x != @stop_x && Gosu::milliseconds - @last_millis > @interval
      if @stop_x > @x
        @angle += @angle == 180 ? -5.0 : 5.0
        @x += @speed * 0.5
        @x = @stop_x if @stop_x < @x
      else
        @angle += @angle == 180 ? 5.0 : -5.0
        @x -= @speed * 0.5
        @x = @stop_x if @stop_x > @x
      end
      @last_millis = Gosu::milliseconds
    end
    if @x == @stop_x
      @angle = 0.0 if @angle < 100 else 180.0
    end
  end

  def draw
    image = @animation[Gosu::milliseconds / 100 % @animation.size]
    image.draw_rot(@x, @y, ZOrder::Cars, @angle)
  end
end
