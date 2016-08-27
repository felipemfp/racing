# This class handles the High Scores menu behavior.
class HighScoresMenuState < MenuState
  def initialize(options = {})
    super options
    @options = [
      @main.lang['option_clear'],
      @main.lang['option_back']
    ]
    @margin_option = [HEIGHT - 65, HEIGHT - 45]
    @margin_score = [30, 150, 25]
    @scores = @main.data['high_scores']
    @scores_label = @main.lang['high_scores']
    @current_option = 1
  end

  def load_assets
    @option_font = Gosu::Font.new(15, name: 'src/media/fonts/Play-Regular.ttf')
    @background = Gosu::Image.new('src/media/images/high-scores-bg.jpg',
                                  tileable: true)
    @option_sample = Gosu::Sample.new('src/media/sounds/menu-option.wav')
    @score_font = Gosu::Font.new(25, name: 'src/media/fonts/Play-Regular.ttf')
    @song = Gosu::Song.new('src/media/sounds/menu.wav')
  end

  def draw
    super
    draw_options
    draw_scores
  end

  def draw_options
    @options.each_with_index do |option, i|
      caption = i == @current_option ? '  ' + option : option
      @option_font.draw(caption, @margin_score[0],
                        @margin_option[i], ZOrder::UI)
    end
  end

  def draw_scores
    @scores.each_with_index do |score, i|
      left_margin = @margin_score[0]
      top_margin = @margin_score[0] + (@margin_score[2] * i)
      @score_font.draw(@scores_label[i], left_margin, top_margin, ZOrder::UI)
      @score_font.draw(score, @margin_score[1], top_margin, ZOrder::UI)
    end
  end

  def handle_choice
    case @current_option
    when 0
      @main.data['high_scores'] = [0, 0, 0, 0, 0]
      @scores = @main.data['high_scores']
    when 1
      @main.state = 0
    end
  end
end
