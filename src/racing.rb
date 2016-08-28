require 'rubygems'
require 'gosu'
require 'json'

require_relative 'utils/lang'

require_relative 'models/state'
require_relative 'models/player'
require_relative 'models/car'
require_relative 'models/road'
require_relative 'models/speedometer'

require_relative 'states/menu_state'
require_relative 'states/game_state'

require_relative 'states/menu_states/main'
require_relative 'states/menu_states/scenario'
require_relative 'states/menu_states/highscores'
require_relative 'states/menu_states/garage'
require_relative 'states/menu_states/options'

require_relative 'states/game_states/oneway'
require_relative 'states/game_states/twoway'

# This module holds the Z orders constants.
module ZOrder
  BACKGROUND, CARS, PLAYER, ELEMENT, COVER, UI = *0..5
end

# This module holds the paths constants.
module Path
  SOURCE = File.dirname(__FILE__).freeze
  FONTS =  File.join(SOURCE, 'media/fonts/').freeze
  IMAGES = File.join(SOURCE, 'media/images/').freeze
  SOUNDS = File.join(SOURCE, 'media/sounds/').freeze
  DATA = File.join(SOURCE, 'data/').freeze
  LANGS = File.join(SOURCE, 'langs/').freeze
end

WIDTH = 512
HEIGHT = 512
CARS = [
  [Path::IMAGES + 'car.png', nil],
  [Path::IMAGES + 'ambulance.png', Path::SOUNDS + 'ambulance.wav'],
  [Path::IMAGES + 'audi.png', nil],
  [Path::IMAGES + 'black_viper.png', nil],
  [Path::IMAGES + 'mini_truck.png', nil],
  [Path::IMAGES + 'mini_van.png', nil],
  [Path::IMAGES + 'police.png', Path::SOUNDS + 'police.wav'],
  [Path::IMAGES + 'taxi.png', nil]
].freeze

# This class is responsible to handle the game.
class GameWindow < Gosu::Window
  attr_accessor :state
  attr_reader :data, :lang

  def initialize
    super WIDTH, HEIGHT
    self.caption = 'Racing'
    @states = [
      MainMenuState, ScenarioMenuState, HighScoresMenuState, GarageMenuState,
      OptionsMenuState, OneWayGameState, TwoWayGameState
    ]
    @state = 0
    @last_state = @state
    load_metadata
    @current_state = @states[@state].new(main: self)
  end

  def load_metadata
    @data = JSON.parse(File.read(Path::DATA + 'data.json'))
    @lang = Lang.new(main: self, lang: @data['config']['language'])
    @is_sound_enable = @data['config']['sound']
    @is_countdown_enable = @data['config']['countdown']
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

  def play_sound(song, looping = false, volume = 1.0, speed = 1.0)
    if song.is_a? Gosu::Song
      song.play(looping) if @is_sound_enable
    elsif @is_sound_enable
      song.play(volume, speed, looping)
    end
  end

  def toggle_music(song = Nil, looping = false)
    @is_sound_enable = !@is_sound_enable
    if song
      if @is_sound_enable
        play_sound(song, looping)
      else
        song.stop
      end
    end
  end

  def toggle_countdown
    @is_countdown_enable = !@is_countdown_enable
    @data['config']['countdown'] = @is_countdown_enable
  end

  def sound_label
    @lang['options_sound'][@is_sound_enable ? 0 : 1]
  end

  def countdown_label
    @lang['options_countdown'][@is_countdown_enable ? 0 : 1]
  end

  def current_difficulty
    difficulty =
      @data['config']['difficulty'][@data['config']['current_difficulty']]
    {
      difficulty: @data['config']['current_difficulty'],
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
    @data['config']['countdown'] = @is_countdown_enable
    File.open(Path::DATA + 'data.json', 'w') do |f|
      f.write(@data.to_json)
    end
    super
  end
end

# This module is responsible to open the game.
module Racing
  module_function

  def open
    window = GameWindow.new
    window.show
  end
end
