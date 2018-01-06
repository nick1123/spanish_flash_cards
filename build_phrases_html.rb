#################################
## Build the javascript

def convert_phrases_to_js
  @convert_phrases_to_js ||= IO.readlines('phrases.txt').map.each_with_index do |line, index|
    arr = line.strip.split(':::').map do |elem|
      elem.strip
    end

    spanish_value = arr[0].gsub('"', '\"')
    english_value = arr[1].gsub('"', '\"')

    #        "1" : { "spanish": "En el cómputo global de las cosas", "english" : "In the global computation of things" },
    "        \"#{index + 1}\" : { \"spanish\" : \"#{spanish_value}\", \"english\" : \"#{english_value}\" },"
  end
end

phrases_count = convert_phrases_to_js.size

phrases_js_text = "      var masterListOfPhrases = {\n" + convert_phrases_to_js.join("\n") + "\n      };"



#################################
## Build the html buttons

# <button type="button" class="btn btn-lg btn-info" onclick="setup( ['5'] );">5</button>
def button_for_phrase(index)
  "<button type=\"button\" class=\"btn btn-lg btn-info\" onclick=\"setup( ['#{index}'] );\">#{index}</button>"
end

# <button type="button" class="btn btn-lg btn-primary" onclick="setup( ['1', '2', '3', '4', '5'] );">1 - 5</button>
def button_for_phrase_group(index)
  return '' if index % 5 != 0

  setup_values = ((index - 4)..index).map {|i| "'#{i}'"}.join(', ')
  "<button type=\"button\" class=\"btn btn-lg btn-primary\" onclick=\"setup( [#{setup_values}] );\">#{index - 4} - #{index}</button>"
end

# <button type="button" class="btn btn-lg btn-success" onclick="setup( ['1', '2', '3', '4', '5'] );">1 - 5</button>
def button_for_phrase_group_all(index, last_index)
  return '' if index != last_index

  setup_values = (1..index).map {|i| "'#{i}'"}.join(', ')
  "<button type=\"button\" class=\"btn btn-lg btn-success\" onclick=\"setup( [#{setup_values}] );\">1 - #{index}</button>"
end

def br_tag(index)
  index % 5 == 0 ? '<br>' : ''
end

buttons = (1..phrases_count).map do |index|
  [
    button_for_phrase(index),
    button_for_phrase_group(index),
    button_for_phrase_group_all(index, phrases_count),
    br_tag(index)
  ]
end.flatten.reject {|elem| elem.empty? }.map {|elem| "            #{elem}"}.join("\n")




#################################
## Build the html page

File.open('phrases_automatically_generated.html', 'w') do |file_handle|
  file_handle.write(
    IO.read('phrases_html_template.txt').sub('INSERT_MASTER_PHRASE_LIST', phrases_js_text).sub('INSERT_BUTTONS', buttons)
  )
end

