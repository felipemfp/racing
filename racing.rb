require 'gosu'

module ZOrder
  Background, Cars, Player, UI = *0..3
end


class Player
  def initialize
    @image= Gosu::Image.new('media/car.png')
    @x, @y, @angle = 0.0
    @score = 0
    @vel = 1.0
  end

  def warp(x, y)
    @x, @y = x, y
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

  def collision(cars)
    cars.each do |car|
      # if Gosu::distance(@x, @y, car.x, car.y) < 70
      if @x > car.x
        if @y > car.y
          if @x - car.x < 50 and @y - car.y < 110
            close
          end
        else
          if @x - car.x < 50 and car.y - @y < 110
            close
          end
        end
      else
        if car.y > @y
          if car.x - @x < 50 and car.y - @y < 110
            close
          end
        else
          if car.x - @x < 50 and @y - car.y < 110
            close
          end
        end
      end
    end
  end

  def draw
    @image.draw_rot(@x, @y, ZOrder::Player, @angle)
  end
end


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



class Road
  def initialize
    @image_a = Gosu::Image.new('media/background.png', :tileable => true)
    @image_b = Gosu::Image.new('media/background.png', :tileable => true)
    @xa = @ya = @xb = 0.0
    @yb = -512.0
    @vel = 5.0
  end

  def accelerate
    @vel *= 1.04
  end

  def move
    @ya += @vel
    @yb += @vel
    if @ya >= 512
      @ya -= 512 * 2
    end
    if @yb >= 512
      @yb -= 512 * 2
    end
  end

  def draw
    @image_a.draw(@xa, @ya, ZOrder::Background)
    @image_b.draw(@xb, @yb, ZOrder::Background)
  end
end


class RacingWindow < Gosu::Window
  def initialize
    super 512, 512
    self.caption = "Racing by felipemfp"


    @last_millis = 0
    @cars_interval = 7500

    @interval = 2

    @road = Road.new

    @player = Player.new
    @player.warp(512/2, 512-90)

    @car_image = [Gosu::Image.new('media/ambulance.png'),
      Gosu::Image.new('media/audi.png'),
      Gosu::Image.new('media/black_viper.png'),
      Gosu::Image.new('media/mini_truck.png'),
      Gosu::Image.new('media/mini_van.png'),
      Gosu::Image.new('media/taxi.png'),
      Gosu::Image.new('media/police.png')]
    @cars = []
  end

  def update
    if (Gosu::milliseconds - @last_millis > @cars_interval)
      @cars << Car.new(@car_image[rand(@car_image.size)])
      @last_millis = Gosu::milliseconds
    end
    if (Gosu::milliseconds / 1000 > @interval)
      @road.accelerate
      @player.accelerate
      @cars.each { |car| car.accelerate }
      if @cars_interval > 1500
        @cars_interval -= 250
      end
      @interval *= 1.2
    end
    if Gosu::button_down? Gosu::KbLeft or Gosu::button_down? Gosu::GpLeft then
      @player.move_left
    elsif Gosu::button_down? Gosu::KbRight or Gosu::button_down? Gosu::GpRight then
      @player.move_right
    else
      @player.reset_angle
    end
    @road.move
    @cars.each { |car| car.move }
    @cars.each do |car|
      if car.y >= 512+140
        car = nil
      end
    end
    @cars = @cars.compact
    @player.collision(@cars)
  end

  def draw
    @player.draw
    @road.draw
    @cars.each { |car| car.draw }
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end

end


window = RacingWindow.new
window.show
