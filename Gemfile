# BeEF's Gemfile

#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
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

gem "thin"
gem "ansi"
gem "term-ansicolor", :require => "term/ansicolor"
gem "dm-core"
gem "json"
gem "data_objects"
gem "dm-sqlite-adapter"
gem "parseconfig"
gem "erubis"
gem "dm-migrations"

# Gems only required one windows
if RUBY_PLATFORM.downcase.include?("mswin")
  gem "win32console"
end

# for the console shell extension
gem "librex", "0.0.52"

# for running unit tests
gem "msfrpc-client"
gem "curb"
gem "test-unit"
gem "selenium"
gem "selenium-webdriver"
# nokogirl is needed by capybara which may require one of the below commands
# sudo apt-get install libxslt-dev libxml2-dev
# sudo port install libxml2 libxslt
gem "capybara"

source "http://rubygems.org"
