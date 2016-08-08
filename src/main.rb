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
    @states = [
      MenuState,
      GameState,
      HighScoresState
    ]
    @state = 0
    @current_state = @states[@state].new(self)
    @last_state = @state
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
end
