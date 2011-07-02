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
class Iframe_above < BeEF::Core::Command
  
  	#
  	# Defines and set up the commmand module.
  	#
	def initialize
		super({
      'Name' => 'iFrame Persistance',
      'Description' => 'Rewrites all links on the webpage to spawn a 100% by 100% iFrame with a source relative to the selected link.',
      'Category' => 'Persistence',
      'Author' => 'passbe',
	    'File' => __FILE__
    })

    set_target({
      'verified_status' =>  VERIFIED_USER_NOTIFY, 
      'browser_name' =>     ALL
    })
   
    use_template!
    
	end

  	# This method is being called when a hooked browser sends some
  	# data back to the framework.
  	#
  	def callback
    		save({'result' => @datastore['result']})
  	end
  
end