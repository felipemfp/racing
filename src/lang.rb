class Lang
  attr_reader :data

  def initialize(lang)
    @path = 'src/lang/'+lang+'.json'
    if !File.file?(@path)
      @path = 'src/lang/en-us.json'
    end
    @data = JSON.parse(File.read(@path))
  end

  def menu
    return @data['menu']
  end

  def high_scores_label
    return @data['high_scores']
  end

  def back
    return @data['option_back']
  end

  def clear
    return @data['option_clear']
  end

  def score_label
    return @data['score_label']
  end

  def cars_option
    return @data['cars_option']
  end
end
