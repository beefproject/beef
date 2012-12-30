#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Lcamtuf_download < BeEF::Core::Command
  
  # set and return all options for this module
  def self.options

    return [{
      'name' => 'real_file_uri', 
      'description' => 'The web accessible URI for the real file.',
      'ui_label' => 'Real File Path',
      'value' => 'http://get.adobe.com/flashplayer/download/?installer=Flash_Player_11_for_Internet_Explorer_(64_bit)&os=Windows%207&browser_type=MSIE&browser_dist=OEM&d=Google_Toolbar_7.0&PID=4166869',
      'width' => '300px' 
      },
      {
      'name' => 'malicious_file_uri',
      'description' => 'The web accessible URI for the malicious file.',
      'ui_label' => 'Malicious File Path',
      'value' => '',
      'width' => '300px'
      },
      { 'name' => 'do_once', 'type' => 'combobox', 'ui_label' => 'Run Once', 'store_type' => 'arraystore',
          'store_fields' => ['do_once'], 'store_data' => [['false'],['true']],
          'valueField' => 'do_once', 'displayField' => 'do_once', 'mode' => 'local', 'value' => 'false', 'autoWidth' => true
      }]
  end

  def post_execute     
    content = {}
    content['result'] = @datastore['result']          
    
    save content   
  end
  
end
