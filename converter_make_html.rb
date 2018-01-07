# Usage
# ruby converter_make_html.rb translation_spanish_toneladas.txt



#################################
## Build the javascript

def convert_phrases_to_js
  @convert_phrases_to_js ||= IO.readlines(ARGV[0]).map.each_with_index do |line, index|
    arr = line.strip.split(':::').map do |elem|
      elem.strip
    end

    spanish_value = arr[0].gsub('"', '\"')
    english_value = arr[1].gsub('"', '\"')

    #        "1" : { "spanish": "cosas", "english" : "things" },
    "        \"#{index + 1}\" : { \"spanish\" : \"#{spanish_value}\", \"english\" : \"#{english_value}\" },"
  end
end

phrases_count = convert_phrases_to_js.size

phrases_js_text = "      var masterListOfPhrases = {\n" + convert_phrases_to_js.join("\n") + "\n      };"



#################################
## Build the html buttons

GROUP_SIZE_SMALL = 5
GROUP_SIZE_BIG   = 25

# <button type="button" class="btn btn-primary" onclick="setup( ['1', '2', '3', '4', '5'] );">1 - 5</button>
def button_for_phrase_group(index, last_index, group_size, button_type)

  if index != last_index && index % group_size != 0
    return ''
  end

  min_value = index - group_size + 1
  max_value = [index, last_index].min

  if index == last_index
    min_value = index - (index % group_size) + 1
    if group_size == last_index
      min_value = 1
    end
  end

  setup_values = (min_value..max_value).map {|i| "'#{i}'"}.join(', ')
  "<button type=\"button\" class=\"btn btn-#{button_type}\" onclick=\"setup( [#{setup_values}] );\">#{min_value} - #{max_value}</button>"
end


def br_tag(index, group_size)
  index % group_size == 0 ? '<br>' : ''
end

buttons = (1..phrases_count).map do |index|
  [
    button_for_phrase_group(index, phrases_count, GROUP_SIZE_SMALL, 'info'),
    button_for_phrase_group(index, phrases_count, GROUP_SIZE_BIG,   'primary'),
    button_for_phrase_group(index, phrases_count, phrases_count,    'success'),
    br_tag(index, GROUP_SIZE_BIG)
  ]
end.flatten.reject {|elem| elem.empty? }.map {|elem| "            #{elem}"}.join("\n")



#################################
## Build the html page

File.open(ARGV[0].sub('translation', 'html').sub('txt', 'html'), 'w') do |file_handle|
  file_handle.write(
    IO.read('phrases_html_template.txt').sub('INSERT_MASTER_PHRASE_LIST', phrases_js_text).sub('INSERT_BUTTONS', buttons)
  )
end

