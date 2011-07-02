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
class Popunder_window < BeEF::Core::Command
  
  	#
  	# Defines and set up the commmand module.
  	#
	def initialize
		super({
      'Name' => 'Pop Under Window',
      'Description' => 'Creates a new discrete pop under window with the beef hook included.<br><br>This module will add another browser node to the tree. It will be a duplicate. This will be addressed in a future release',
      'Category' => 'Persistence',
      'Author' => 'ethicalhack3r',
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