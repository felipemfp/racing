require 'rubygems'
require 'gosu'
require 'json'
require_relative 'state'
require_relative 'player'
require_relative 'car'
require_relative 'road'
require_relative 'lang'
require_relative 'menuState'
require_relative 'gameState'
require_relative 'scenarioState'
require_relative 'oneWayGameState'
require_relative 'twoWayGameState'
require_relative 'highScoresState'
require_relative 'garageState'
require_relative 'optionsState'

WIDTH = 512
HEIGHT = 512
CARS = [
  ['src/media/images/car.png', nil],
  ['src/media/images/ambulance.png', 'src/media/sounds/ambulance.wav'],
  ['src/media/images/audi.png', nil],
  ['src/media/images/black_viper.png', nil],
  ['src/media/images/mini_truck.png', nil],
  ['src/media/images/mini_van.png', nil],
  ['src/media/images/police.png', 'src/media/sounds/police.wav'],
  ['src/media/images/taxi.png', nil]
].freeze

module ZOrder
  Background, Cars, Player, Element, Cover, UI = *0..5
end

class MainWindow < Gosu::Window
  attr_accessor :state
  attr_reader :data, :lang

  def initialize
    super WIDTH, HEIGHT
    self.caption = 'Racing'

    @states = [
      MenuState,
      ScenarioState,
      HighScoresState,
      GarageState,
      OptionsState,
      OneWayGameState,
      TwoWayGameState
    ]
    @state = 0
    @last_state = @state
    @data = JSON.parse(File.read('src/data/data.json'))
    @lang = Lang.new(main: self, lang: @data['config']['language'])
    @is_sound_enable = @data['config']['sound']

    @current_state = @states[@state].new(main: self)
  end

  def update
    if @state != @last_state
      @current_state = @states[@state].new(main: self)
      @last_state = @state
    end
    @current_state.update
  end

  def draw
    @current_state.draw
  end

  def button_down(id)
    @current_state.button_down(id)
  end

  def play_sound(_song, _loop = false, _volume = 1.0, _speed = 1.0)
    if _song.is_a? Gosu::Song
      _song.play(_loop) if @is_sound_enable
    else
      _song.play(_volume, _speed, _loop) if @is_sound_enable
    end
  end

  def toggle_music(_song = Nil, _loop = false)
    @is_sound_enable = !@is_sound_enable
    if _song
      if @is_sound_enable
        play_sound(_song, _loop)
      else
        _song.stop
      end
    end
  end

  def get_sound_label
    if @is_sound_enable
      return @lang.options_sound[0]
    else
      return @lang.options_sound[1]
    end
  end

  def current_difficulty
    difficulty = @data['config']['difficulty'][@data['config']['current_difficulty']]
    return {
      cars_wave: difficulty['cars_wave'],
      cars_move: difficulty['cars_move'],
      score_factor: difficulty['score_factor']
    }
  end

  def restart
    @current_state = @states[@state].new(main: self)
  end

  def close
    @data['config']['sound'] = @is_sound_enable
    File.open('src/data/data.json', 'w') do |f|
      f.write(@data.to_json)
    end
    super
  end
end
