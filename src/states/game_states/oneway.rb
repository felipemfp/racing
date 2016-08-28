# This class is responsible to extend the on game behavior
# to a one way scenario.
class OneWayGameState < GameState
  MODE_INDEX = 0

  def initialize(options = {})
    super({
      player_margin_left: 175.0,
      player_margin_right: 335.0,
      cars_angle: [0.0],
      cars_pos: [180.0, 255.0, 330.0],
      cars_wave: options[:main].current_difficulty[:cars_wave][MODE_INDEX],
      cars_move: options[:main].current_difficulty[:cars_move],
      score_factor: options[:main].current_difficulty[:score_factor]
    }.merge(options))
  end

  def load_assets
    super
    @road = Road.new(Path::IMAGES + 'background-one.png')
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

  def clean_cars_outdated
    @cars.reject! do |car|
      if car.y >= 512 + 140
        car.sample.stop if car.sample
        @cars_outdated += 1
        reject = true
      end
      @last_car = car if
        @last_car.nil? || @last_car.y < car.y + @car_hit_distance
      reject
    end
  end

  def handle_possible_collision
    return unless @cars.size > 1 && @last_car
    @cars.each_with_index do |car, i|
      @cars[i].speed = @last_car.speed if
        @last_car.x == car.x && @last_car.y < car.y + @car_hit_distance
    end
    @last_car = nil
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
    @last_car = nil
    clean_cars_outdated
    super
    handle_possible_collision
  end

  def draw
    super
  end
end
