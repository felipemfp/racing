class HighScoresState
  def initialize(main)
    @main = main
    @option_font = Gosu::Font.new(15, name: 'src/media/fonts/NeedforFont.ttf')
    @options = [
      ['Clear', 30, HEIGHT - 65],
      ['Back', 30, HEIGHT - 45]
    ]
    @current_option = 0
    @background = Gosu::Image.new('src/media/images/high-scores-bg.jpg', tileable: true)
    @option_sample = Gosu::Sample.new('src/media/sounds/menu-option.wav')
    @song = Gosu::Song.new('src/media/sounds/menu.wav')
    @song.play(true)

    @data = JSON.parse(File.read('src/data/data.json'))
    @score_font = Gosu::Font.new(25, name: 'src/media/fonts/NeedforFont.ttf')
  end

  def update
  end

  def draw
    @background.draw(0, 0, ZOrder::Background)
    @options.each_with_index do |option, i|
      caption = option[0]
      caption = '  ' + caption if i == @current_option
      @option_font.draw(caption, option[1], option[2], ZOrder::UI)
    end
    @score_font.draw('1st', 30, 30, ZOrder::UI)
    @score_font.draw('2nd', 30, 55, ZOrder::UI)
    @score_font.draw('3rd', 30, 80, ZOrder::UI)
    @score_font.draw('4th', 30, 105, ZOrder::UI)
    @score_font.draw('5th', 30, 130, ZOrder::UI)
    @score_font.draw((@data['high_scores'][0]).to_s, 150, 30, ZOrder::UI)
    @score_font.draw((@data['high_scores'][1]).to_s, 150, 55, ZOrder::UI)
    @score_font.draw((@data['high_scores'][2]).to_s, 150, 80, ZOrder::UI)
    @score_font.draw((@data['high_scores'][3]).to_s, 150, 105, ZOrder::UI)
    @score_font.draw((@data['high_scores'][4]).to_s, 150, 130, ZOrder::UI)
  end

  def button_down(id)
    if id == Gosu::KbReturn || id == Gosu::GpButton2
      case @current_option
      when 0
        @data['high_scores'] = [0, 0, 0, 0, 0]
        File.open('src/data/data.json', 'w') do |f|
          f.write(@data.to_json)
        end
      when 1
        @main.state = 0
      end
    elsif id == Gosu::KbDown || id == Gosu::GpDown
      @option_sample.play
      @current_option += 1
      @current_option = 0 if @current_option >= @options.size
    elsif id == Gosu::KbUp || id == Gosu::GpUp
      @option_sample.play
      @current_option -= 1
      @current_option = @options.size - 1 if @current_option < 0
    elsif id == Gosu::KbEscape || id == Gosu::GpButton1
      @main.state = 0
    end
  end
end
