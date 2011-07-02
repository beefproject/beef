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
# The following file contains patches for WEBrick.
module WEBrick
  
  class HTTPServer < ::WEBrick::GenericServer
    
    # I'm patching WEBrick so it does not log http requests anymore.
    # The reason being that it seems to considerably slow down BeEF which receives
    # numerous requests simultaneously. Additionally, it was also found to crash
    # the thread when not being able to write to the log file (which happened when
    # overloaded).
    def access_log(config, req, res); return; end
    
  end
  
end