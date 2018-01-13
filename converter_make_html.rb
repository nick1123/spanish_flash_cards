# Usage
# ruby converter_make_html.rb translation_spanish_toneladas.txt



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

# <button type="button" class="btn btn-primary" onclick="setup( ['1', '2', '3', '4', '5'] );">1 - 5</button>
def button_for_phrase_group(index, translations, group_size, button_type)

  last_index = translations.keys.sort[-1]
  if index != last_index && index % group_size != 0
    return ''
  end

  min_value = index - group_size + 1
  max_value = [index, last_index].min

  # Edge case:  End of the list
  if index == last_index
    min_value = index - (index % group_size) + 1
    if group_size == last_index
      min_value = 1
    end
  end

  setup_values = (min_value..max_value).map {|index| "'#{index}'"}.join(', ')
  display_values = (min_value..max_value).map {|index| translations[index][:spanish_value]}.join(', ')

  if index == last_index && group_size == last_index
    display_values = "Review All"
  end
  "<button type=\"button\" class=\"btn btn-#{button_type}\" onclick=\"setup( [#{setup_values}] );\">#{display_values}</button>"
end


def button_for_small_group(index, translations, group_size, button_type, is_review_button)

  last_index = translations.keys.sort[-1]
  if index != last_index && index % group_size != 0
    return ''
  end

  min_value = index - group_size + 1
  max_value = [index, last_index].min

  # Edge case:  End of the list
  if index == last_index
    min_value = index - (index % group_size) + 1
  end

  setup_values   = (min_value..max_value).map {|index| "'#{index}'"}.join(', ')
  display_values = (min_value..max_value).map {|index| index.to_s + ": " + translations[index][:spanish_value]}.join(', ')

  if is_review_button
    display_values = "Review"
  end


  # puts "************** index #{index}   min #{min_value}   max #{max_value}"
  "<button type=\"button\" class=\"btn btn-#{button_type}\" onclick=\"setup( [#{setup_values}] );\">#{display_values}</button>"
end


def br_tag(index, group_size)
  index % group_size == 0 ? '<br>' : ''
end

buttons = (1..phrases_count).map do |index|
  [
    button_for_small_group(index, words_and_translations, GROUP_SIZE_SMALL, 'info',   false),
    # button_for_small_group(index, words_and_translations, GROUP_SIZE_BIG,   'primary', true),
    # button_for_phrase_group(index, words_and_translations, GROUP_SIZE_SMALL, 'info'),
    # button_for_phrase_group(index, words_and_translations, GROUP_SIZE_BIG,   'primary'),
    # button_for_phrase_group(index, words_and_translations, phrases_count,    'success'),
    br_tag(index, GROUP_SIZE_BIG)
  ]
end.flatten.reject {|elem| elem.empty? }.map {|elem| "            #{elem}"}.join("\n")


# [
#   [1, {:english_value=>"on, in", :spanish_value=>"en"}], 
#   [2, {:english_value=>"the", :spanish_value=>"el"}], 
#   [3, {:english_value=>"calculation", :spanish_value=>"cómputo"}]
# ]
def make_button(slice, button_type)
  indexes = slice.map {|arr| arr[0]}.map {|index| "'#{index}'"}.join(', ')
  spanish_values = slice.map {|arr| arr[1][:spanish_value]}.join(', ')
  "<button type=\"button\" class=\"btn btn-#{button_type}\" onclick=\"setup( [#{indexes}] );\">#{spanish_values}</button>"
end

def button_position(slice)
  slice.map {|arr| arr[0]}.max
end

buttons_hash = {}

# puts words_and_translations.inspect
words_and_translations.each_slice(GROUP_SIZE_SMALL) do |slice|
  buttons_hash[button_position(slice)] ||= []
  buttons_hash[button_position(slice)] << make_button(slice, 'info')
end


puts buttons_hash.inspect


#################################
## Build the html page

File.open(ARGV[0].sub('translation', 'html').sub('txt', 'html'), 'w') do |file_handle|
  file_handle.write(
    IO.read('phrases_html_template.txt').sub('INSERT_MASTER_PHRASE_LIST', phrases_js_text).sub('INSERT_BUTTONS', buttons)
  )
end

