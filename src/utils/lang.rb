# This class is responsible to handle the i18n support.
class Lang
  attr_reader :languages

  def initialize(options = {})
    @lang = options[:lang]
    @main = options[:main]
    @data = open_language(@lang)
    @languages = all_languages
  end

  def open_language(lang)
    @path_to_file = 'src/langs/' + lang + '.json'
    @path_to_file = 'src/langs/en.json' unless File.file?(@path_to_file)
    JSON.parse(File.read(@path_to_file))
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

  def [](label)
    @data[label]
  end
end
