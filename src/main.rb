require 'rubygems'
require 'gosu'
require 'json'
require_relative 'state'
require_relative 'player'
require_relative 'car'
require_relative 'road'
require_relative 'menuState'
require_relative 'gameState'
require_relative 'highScoresState'
require_relative 'garageState'

WIDTH = 512
HEIGHT = 512
CARS = [
  'src/media/images/car.png',
  'src/media/images/ambulance.png',
  'src/media/images/audi.png',
  'src/media/images/black_viper.png',
  'src/media/images/mini_truck.png',
  'src/media/images/mini_van.png',
  'src/media/images/police.png',
  'src/media/images/taxi.png'
].freeze

module ZOrder
  Background, Texture, Cars, Player, UI = *0..4
end

class MainWindow < Gosu::Window
  attr_accessor :state
  attr_reader :data

  def initialize
    super WIDTH, HEIGHT
    self.caption = 'Racing'

    @states = [
      MenuState,
      GameState,
      HighScoresState,
      GarageState
    ]
    @state = 0
    @current_state = @states[@state].new(main:self)
    @last_state = @state
    @data = JSON.parse(File.read('src/data/data.json'))
    @is_sound_enable = true
  end

  def update
    if @state != @last_state
      @current_state = @states[@state].new(main:self)
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

  def play_sound(_song, _loop = false)
    if _song.is_a? Gosu::Song
      _song.play(_loop) if @is_sound_enable
    else
      _song.play if @is_sound_enable
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
      return 'Sound On'
    else
      return 'Sound Off'
    end
  end
end
