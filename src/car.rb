class Car
  attr_reader :x, :y, :song
  attr_accessor :sample

  def initialize(animation_file, song_file)
    pos = [180.0, 255.0, 330.0]
    @animation = Gosu::Image.load_tiles(animation_file, 140, 140)
    @song = Gosu::Sample.new(song_file) if song_file
    @x = pos.sample
    @y = rand(100.0..170.0) * -1
    @angle = 0.0
    @vel = rand(2.0..3.0)
  end

  def warp(x, y)
    @x = x
    @y = y
  end

  def accelerate
    @vel *= 1.05
  end

  def move
    @y += @vel
  end

  def draw
    image = @animation[Gosu::milliseconds / 100 % @animation.size]
    image.draw_rot(@x, @y, ZOrder::Cars, @angle)
  end
end
