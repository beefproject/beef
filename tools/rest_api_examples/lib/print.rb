# print wrappers
def print_debug s
  pp s if @debug
end
def print_verbose s
  puts "[*] #{s}".gray if @verbose
end
def print_status s
  puts "[*] #{s}".blue
end
def print_good s
  puts "[+] #{s}".green
end
def print_error s
  puts "[!] Error: #{s}".red
end
