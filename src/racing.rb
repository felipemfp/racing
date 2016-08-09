require_relative 'main'

module Racing
  def self.open
    window = MainWindow.new
    window.show
  end
end
