#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe 'BeEF Security Checks' do
  it 'dangerous eval usage' do
    Dir['**/*.rb'].each do |path|
      File.open(path) do |f|
        next if /#{File.basename(__FILE__)}/.match(path) # skip this file
        next if %r{/msf-test/}.match(path) # skip this file
        next if %r{extensions/dns}.match(path) # skip this file

        f.grep(/\Weval\W/im) do |line|
          # check if comment starting with the '#' character
          clean_line = line.downcase.gsub(/[ ]/, "")
          if clean_line[0] != '#' # check first non-whitespace position
            raise "Illegal use of 'eval' found in\n Path: #{path}\nLine:  #{line}"
          end 
        end
      end
    end
  end
end
