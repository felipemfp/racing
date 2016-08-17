class TwoWayGameState < GameState
  def initialize(options = {})
    super({
      player_margin_left: 135.0,
      player_margin_right: 385.0,
      cars_angle: [180.0, 0.0],
      cars_pos: [140.0, 215.0, 300.0, 375.0],
      cars_wave: 2,
      cars_move: true
    }.merge(options))

    @cars_interval = 7500

    @distance = 0
    @distance_per_car = 7.5
    @distance_last_car = 0

    @cars_outdated = 0
    @cars_interval = 10
    @cars_from_now = 0
    @car_hit_distance = 145

    @interval = 2
    @road = Road.new('src/media/images/background-two.png')

    @last_going_car = nil
    @last_coming_car = nil
  end

  def update
    if @alive
      if !@paused
        @last_going_car = nil
        @last_coming_car = nil

        @cars.reject! {|car|
          reject = false
          if car.y >= 512 + 140
            car.sample.stop if car.sample
            @cars_outdated += 1
            reject = true
          end
          if car.angle == 180
            @last_coming_car = car if @last_coming_car == nil || @last_coming_car.y < car.y + @car_hit_distance
          else
            @last_going_car = car if @last_going_car == nil || @last_going_car.y < car.y + @car_hit_distance
          end
          reject
        }

        if @cars.size > 1 && (@last_going_car != nil || @last_coming_car)
          @cars.each_with_index do |car, i|
            if car.angle == 180
              @cars[i].set_speed(@last_coming_car.speed) if @last_coming_car.x == car.x && @last_coming_car.y < car.y + @car_hit_distance
            else
              @cars[i].set_speed(@last_going_car.speed) if @last_going_car.x == car.x && @last_going_car.y < car.y + @car_hit_distance
            end
          end
          @last_going_car = nil
          @last_coming_car = nil
        end

        if @cars_outdated - @cars_from_now == @cars_interval
          @distance_per_car -= 0.5
          @cars_from_now = @cars_outdated
        end
      end
    end
    super
  end

  def draw
    super
  end
end
