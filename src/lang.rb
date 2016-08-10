class Lang
  attr_reader :data, :languages

  def initialize(options = {})
    @lang = options[:lang]
    @main = options[:main]

    @data = get_lang(@lang)
    @languages = get_all
  end

  def get_lang(lang)
    @path = 'src/lang/'+lang+'.json'
    if !File.file?(@path)
      @path = 'src/lang/en-us.json'
    end
    return JSON.parse(File.read(@path))
  end

  def get_all
    path = 'src/lang/'
    lang_files = Dir.entries(path).select {|f| !File.directory? f}
    languages = []
    lang_files.each do |language|
      name = JSON.parse(File.read(path + language))['language']
      value = language.split('.')[0]
      languages.push([name, value])
    end
    return languages
  end

  def switch
    current = @languages.find { |l| l[1] == @main.data['config']['language'] }
    index = @languages.index(current)
    if index == @languages.size - 1
      index = 0
    else
      index += 1
    end
    current = @languages[index]
    @data = get_lang(current[1])
    @main.data['config']['language'] = current[1]
    return current
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

  def options
    return @data['options']
  end

  def options_sound
    return @data['options_sound']
  end
end
