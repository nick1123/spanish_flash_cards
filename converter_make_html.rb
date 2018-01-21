# Usage
# ruby converter_make_html.rb translation_spanish_toneladas.txt

require 'pp'


#################################
## Build the javascript

def words_and_translations
  @words_and_translations ||= IO.readlines(ARGV[0]).map.each_with_index do |line, index|
    arr = line.strip.split(':::').map do |elem|
      elem.strip
    end

    spanish_value = arr[0].gsub('"', '\"')
    english_value = arr[1].gsub('"', '\"')

    [index + 1, {english_value: english_value, spanish_value: spanish_value}]

  end.to_h
end

def convert_to_js(translations)
  "      var masterListOfPhrases = {\n" + IO.readlines(ARGV[0]).map.each_with_index do |line, index|
    arr = line.strip.split(':::').map do |elem|
      elem.strip
    end

    spanish_value = arr[0].gsub('"', '\"')
    english_value = arr[1].gsub('"', '\"')

    js_index = index + 1

    #        "1" : { "spanish": "cosas", "english" : "things" },
    "        \"#{js_index}\" : { \"spanish\" : \"#{spanish_value}\", \"english\" : \"#{english_value}\" },"
  end.join("\n") + "\n      };"
end

phrases_count = words_and_translations.keys.size

phrases_js_text = convert_to_js(words_and_translations)




#################################
## Build the html buttons

def group_size_small
  (ARGV[1] || 5).to_i
end

GROUP_SIZE_SMALL = group_size_small
GROUP_SIZE_BIG   = GROUP_SIZE_SMALL * 5

# [
#   [1, {:english_value=>"on, in", :spanish_value=>"en"}], 
#   [2, {:english_value=>"the", :spanish_value=>"el"}], 
#   [3, {:english_value=>"calculation", :spanish_value=>"cómputo"}]
# ]
def make_button(slice, button_type, display_numbers=false)
  indexes = slice.map {|arr| arr[0]}.map {|index| "'#{index}'"}.join(', ')

  spanish_values = slice.map {|arr| arr[1][:spanish_value]}.join(', ')
  if display_numbers
    numbers = slice.map {|arr| arr[0]}
    spanish_values = "#{numbers[0]} - #{numbers[-1]}"
  end

  "<button type=\"button\" class=\"btn btn-#{button_type}\" onclick=\"setup( [#{indexes}] );\">#{spanish_values}</button>"
end

def button_position(slice)
  slice.map {|arr| arr[0]}.max
end

buttons_hash = {}

words_and_translations.each_slice(GROUP_SIZE_SMALL) do |slice|
  buttons_hash[button_position(slice)] ||= []
  buttons_hash[button_position(slice)] << make_button(slice, 'info')
end

words_and_translations.each_slice(GROUP_SIZE_BIG) do |slice|
  buttons_hash[button_position(slice)] ||= []
  buttons_hash[button_position(slice)] << make_button(slice, 'primary', true)
  buttons_hash[button_position(slice)] << "<br>"
end

words_and_translations.each_slice(phrases_count) do |slice|
  buttons_hash[button_position(slice)] ||= []
  buttons_hash[button_position(slice)] << make_button(slice, 'success', true)
end


buttons_html = buttons_hash.keys.sort.map {|key| buttons_hash[key].join("\n") }.join("\n")

#################################
## Build the html page

File.open(ARGV[0].sub('translation', 'html').sub('txt', 'html'), 'w') do |file_handle|
  file_handle.write(
    IO.read('phrases_html_template.txt').sub('INSERT_MASTER_PHRASE_LIST', phrases_js_text).sub('INSERT_BUTTONS', buttons_html)
  )
end

