# This class is responsible to extend the on game behavior
# to a two way scenario.
class TwoWayGameState < GameState
  MODE_INDEX = 1

  def initialize(options = {})
    super({
      player_margin_left: 135.0,
      player_margin_right: 385.0,
      cars_angle: [180.0, 0.0],
      cars_pos: [140.0, 215.0, 300.0, 375.0],
      cars_wave: options[:main].current_difficulty[:cars_wave][MODE_INDEX],
      cars_move: options[:main].current_difficulty[:cars_move],
      score_factor: options[:main].current_difficulty[:score_factor]
    }.merge(options))
  end

  def load_assets
    super
    @road = Road.new(Path::IMAGES + 'background-two.png')
  end

  def load_properties
    super
    @cars_interval = 7500
    @distance = 0
    @distance_per_car = 7.5
    @distance_last_car = 0
    @cars_outdated = 0
    @cars_interval = 10
    @cars_from_now = 0
    @car_hit_distance = 145
    @interval = 2
  end

  def update_last_cars(car)
    if car.angle == 180
      @last_coming_car = car if @last_coming_car.nil? ||
                                @last_coming_car.y < car.y + @car_hit_distance
    elsif @last_going_car.nil? ||
          @last_going_car.y < car.y + @car_hit_distance
      @last_going_car = car
    end
  end

  def clean_cars_outdated
    @cars.reject! do |car|
      if car.y >= 512 + 140
        car.sample.stop if car.sample
        @cars_outdated += 1
        reject = true
      end
      update_last_cars(car)
      reject
    end
  end

  def handle_possible_collision_going(car, i)
    return unless @last_going_car
    @cars[i].speed = @last_going_car.speed if
      @last_going_car.x == car.x &&
      @last_going_car.y < car.y + @car_hit_distance
  end

  def handle_possible_collision_coming(car, i)
    return unless @last_coming_car
    @cars[i].speed = @last_coming_car.speed if
      @last_coming_car.x == car.x &&
      @last_coming_car.y < car.y + @car_hit_distance
  end

  def handle_possible_collision
    return unless @cars.size > 1 && (@last_going_car || @last_coming_car)
    @cars.each_with_index do |car, i|
      if car.angle == 180
        handle_possible_collision_coming(car, i)
      else
        handle_possible_collision_going(car, i)
      end
    end
    @last_going_car = nil
    @last_coming_car = nil
  end

  def handle_progression
    super
    if @cars_outdated - @cars_from_now == @cars_interval
      @distance_per_car -= 0.5
      @cars_from_now = @cars_outdated
    end
  end

  def update
    return unless @alive && !@paused
    @last_going_car = nil
    @last_coming_car = nil
    clean_cars_outdated
    super
    handle_possible_collision
  end

  def draw
    super
  end
end
