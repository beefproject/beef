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
# Uses methods described here:
# http://www.itsecuritysolutions.org/2010-03-29_fingerprinting_browsers_using_protocol_handlers/

class Browser_fingerprinting < BeEF::Core::Command

  def post_execute
    content = {}
    content['browser_type'] = @datastore['browser_type'] if not @datastore['browser_type'].nil?
    content['browser_version'] = @datastore['browser_version'] if not @datastore['browser_version'].nil?
    if content.empty?
      content['fail'] = 'Failed to fingerprint browser.'
    end
    save content
  end

end
