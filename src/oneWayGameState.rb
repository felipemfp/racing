class OneWayGameState < GameState
  def initialize(options = {})
    super options

    @cars_interval = 7500

    @distance = 0
    @distance_per_car = 7.5
    @distance_last_car = 0

    @cars_outdated = 0
    @cars_interval = 10
    @cars_from_now = 0
    @car_hit_distance = 145

    @interval = 2
    @road = Road.new('src/media/images/background-one.png')

    @cars = []
    @last_car = nil
  end

  def update
    if @alive
      if !@paused
        @last_car = nil

        @cars.reject! {|car|
          reject = false
          if car.y >= 512 + 140
            car.sample.stop if car.sample
            @cars_outdated += 1
            reject = true
          end
          @last_car = car if @last_car == nil || @last_car.y < car.y + @car_hit_distance
          reject
        }

        if @cars.size > 1 && @last_car != nil
          @cars.each_with_index do |car, i|
            @cars[i].set_speed(@last_car.speed) if @last_car.x == car.x && @last_car.y < car.y + @car_hit_distance
          end
          @last_car = nil
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
