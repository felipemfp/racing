require 'gosu'
require 'json'
require_relative 'menuState'
require_relative 'gameState'
require_relative 'highScoresState'
require_relative 'player'
require_relative 'car'
require_relative 'road'

WIDTH = 512
HEIGHT = 512

module ZOrder
  Background, Texture, Cars, Player, UI = *0..4
end

class MainWindow < Gosu::Window
  attr_accessor :state

  def initialize
    super WIDTH, HEIGHT
    self.caption = 'Racing'
    @is_sound_enable = false
    @states = [
      MenuState,
      GameState,
      HighScoresState
    ]
    @state = 0
    @current_state = @states[@state].new(self)
    @last_state = @state
    @song = Gosu::Song.new('src/media/sounds/menu.wav')
  end

  def update
    if @state != @last_state
      @current_state = @states[@state].new(self)
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

  def play_sound(song, loop = false)
    if song.is_a? Gosu::Song
      song.play(loop) if @is_sound_enable
    else
      song.play if @is_sound_enable
    end
  end

  def toggle_music
    if @is_sound_enable
      @song.stop
    else
      @song.play(true)
    end
    @is_sound_enable = !@is_sound_enable
  end

  def get_sound_label
    if @is_sound_enable
      return 'Sound On'
    else
      return 'Sound Off'
    end
  end
end
