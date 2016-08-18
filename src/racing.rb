require_relative 'main'

# This module is responsible to open the game.
module Racing
  module_function

  def open
    window = MainWindow.new
    window.show
  end
end
