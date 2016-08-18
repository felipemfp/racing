# This class is responsible to handle the i18n support.
class Lang
  attr_reader :data, :languages

  def initialize(options = {})
    @lang = options[:lang]
    @main = options[:main]
    @data = open_language(@lang)
    @languages = all_languages
  end

  def open_language(lang)
    @path = 'src/langs/' + lang + '.json'
    @path = 'src/langs/en.json' unless File.file?(@path)
    JSON.parse(File.read(@path))
  end

  def all_languages
    path = 'src/langs/'
    lang_files = Dir.entries(path).select { |f| !File.directory? f }
    languages = []
    lang_files.each do |language|
      name = JSON.parse(File.read(path + language))['language']
      value = language.split('.')[0]
      languages.push([name, value])
    end
    languages
  end

  def switch
    current = current_language
    index = @languages.index(current)
    index = index == @languages.size - 1 ? 0 : index + 1
    current = @languages[index]
    @data = open_language(current[1])
    @main.data['config']['language'] = current[1]
    current
  end

  def current_language
    @languages.find { |l| l[1] == @main.data['config']['language'] }
  end

  def menu
    @data['menu']
  end

  def high_scores_label
    @data['high_scores']
  end

  def back
    @data['option_back']
  end

  def clear
    @data['option_clear']
  end

  def score_label
    @data['score_label']
  end

  def cars_option
    @data['cars_option']
  end

  def options
    @data['options']
  end

  def options_sound
    @data['options_sound']
  end

  def options_countdown
    @data['options_countdown']
  end

  def pause_options
    @data['pause_options']
  end

  def countdown
    @data['countdown']
  end
end
