#
# @note Add color to String object
#
class String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  {:red => 31,
   :green => 32,
   :yellow => 33,
   :blue => 34,
   :pink => 35,
   :cyan => 36,
   :white => 37
  }.each { |color, code|
    define_method(color) { colorize(code) }
  }
end

#
# @note handle output
#
def print_status(msg='')
  puts '[*] '.blue + msg
end

def print_error(msg='')
  puts '[!] '.red + "Error: #{msg}"
end

def print_good(msg='')
  puts '[+] '.green + msg
end

def print_warning(msg='')
  puts '[!] '.yellow + "Warning: #{msg}"
end

def print_debug(msg='')
  puts "#{msg}" if $VERBOSE
end

