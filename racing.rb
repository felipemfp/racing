require 'gosu'
load 'player.rb'
load 'car.rb'
load 'road.rb'

WIDTH, HEIGHT = 512, 512

module ZOrder
  Background, Cars, Player, UI = *0..3
end

class RacingWindow < Gosu::Window
  def initialize
    super WIDTH, HEIGHT
    self.caption = "Racing by felipemfp"
    @score_font = Gosu::Font.new(20)
    @gameover = Gosu::Image.from_text(
        self, 'GAME OVER', Gosu.default_font_name, 45)

    @last_millis = 0
    @cars_interval = 7500

    @interval = 2

    @road = Road.new

    @player = Player.new
    @player.warp(WIDTH/2, HEIGHT-90)

    @car_image = [Gosu::Image.new('media/ambulance.png'),
      Gosu::Image.new('media/audi.png'),
      Gosu::Image.new('media/black_viper.png'),
      Gosu::Image.new('media/mini_truck.png'),
      Gosu::Image.new('media/mini_van.png'),
      Gosu::Image.new('media/taxi.png'),
      Gosu::Image.new('media/police.png')]
    @cars = []

    @alive = true

    @car_brake = Gosu::Sample.new("media/car-brake.wav")
    @car_speed = Gosu::Song.new("media/car-speed.wav")

    @car_speed.play(true)
  end

  def update
    if @alive
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
      if @player.collision?(@cars)
        @car_brake.play
        @car_speed.stop
        @alive = false
      end
      @player.set_score(Gosu::milliseconds/226)
    end
  end

  def draw
    @player.draw
    @road.draw
    @cars.each { |car| car.draw }
    @score_font.draw("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xff_f5f5f5)
    if !@alive
      @gameover.draw_rot(WIDTH/2, HEIGHT/2, ZOrder::UI, 0.0)
    end
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end

end


window = RacingWindow.new
window.show
