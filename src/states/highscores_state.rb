class HighScoresState < State
  def initialize(options = {})
    super options
    @option_font = Gosu::Font.new(15, name: 'src/media/fonts/Play-Regular.ttf')
    @options = [
      @main.lang['option_clear'],
      @main.lang['option_back']
    ]
    @margin_option = [HEIGHT - 65, HEIGHT - 45]
    @margin_score = [30, 150, 25]
    @scores = @main.data['high_scores']
    @scores_label = @main.lang['high_scores']
    @current_option = 1
    @background = Gosu::Image.new('src/media/images/high-scores-bg.jpg', tileable: true)
    @option_sample = Gosu::Sample.new('src/media/sounds/menu-option.wav')
    @score_font = Gosu::Font.new(25, name: 'src/media/fonts/Play-Regular.ttf')
    @song = Gosu::Song.new('src/media/sounds/menu.wav')
    @main.play_sound(@song, true)
  end

  def update
  end

  def draw
    @background.draw(0, 0, ZOrder::BACKGROUND)
    @options.each_with_index do |option, i|
      caption = option
      caption = '  ' + caption if i == @current_option
      @option_font.draw(caption, @margin_score[0], @margin_option[i], ZOrder::UI)
    end
    @scores.each_with_index do |score, i|
      left_margin = @margin_score[0]
      top_margin = @margin_score[0] + (@margin_score[2] * i)
      @score_font.draw(@scores_label[i], left_margin, top_margin, ZOrder::UI)
      @score_font.draw(score, @margin_score[1], top_margin, ZOrder::UI)
    end
  end

  def button_down(id)
    if id == Gosu::KbReturn || id == Gosu::GpButton2
      case @current_option
      when 0
        @main.data['high_scores'] = [0, 0, 0, 0, 0]
        @scores = @main.data['high_scores']
      when 1
        @main.state = 0
        end
    elsif id == Gosu::KbDown || id == Gosu::GpDown
      @main.play_sound(@option_sample)
      @current_option += 1
      @current_option = 0 if @current_option >= @options.size
    elsif id == Gosu::KbUp || id == Gosu::GpUp
      @main.play_sound(@option_sample)
      @current_option -= 1
      @current_option = @options.size - 1 if @current_option < 0
    elsif id == Gosu::KbEscape || id == Gosu::GpButton1
      @main.state = 0
    end
  end
end
