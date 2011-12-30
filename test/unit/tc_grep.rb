#
#   Copyright 2011 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
require 'test/unit'

class TC_Grep < Test::Unit::TestCase

  def test_grep_eval
    Dir['../../**/*.rb'].each do |path|
      File.open( path ) do |f|
        next if /tc_grep.rb/.match(path) # skip this file
        next if /\/msf-test\//.match(path) # skip this file
        f.grep( /\Weval\W/im ) do |line|
          assert(false, "Illegal use of 'eval' in framework: " + path + ':' + line)
        end
      end
    end
    
  end

end
