# Usage
# ruby converter_make_word_list.rb text_spanish_toneladas.txt

def file_name_of_text
  ARGV[0]
end

def file_name_of_translation
  file_name_of_text.sub('text', 'translation')
end

File.open(file_name_of_translation, 'w') do |file_handle|
  file_handle.write(
    IO.read(file_name_of_text).downcase.gsub(/\.|\,|\:|\!|\?|¿|\—|\-|»|«|\(|\)|¡|\;|\"|\{|\}|\d+|\|/, ' ').split(/\s+/).select{|word| word.size > 0}.uniq.map {|elem| "#{elem} ::: "}.join("\n")
  )
end