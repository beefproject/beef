#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# Phonegap_keychain
#

class Phonegap_keychain < BeEF::Core::Command
  
    def self.options
        return [{
            'name' => 'servicename', 
            'description' => 'Service name', 
            'ui_label'=>'Service name', 
            'value' => 'ServiceNameTest',
            'width' => '300px'
            
            },{
            'name' => 'key', 
            'description' => 'Key', 
            'ui_label'=>'Key', 
            'value' => 'TestKey',
            'width' => '300px'
            },{
            'name' => 'value', 
            'description' => 'Value', 
            'ui_label'=>'Value', 
            'value' => 'TestValue',
            'width' => '100px'
            },{
            'name' => 'action', 
            'type' => 'combobox',
            'ui_label' => 'Action Type',
            'store_type' => 'arraystore', 
            'store_fields' => ['action'], 
            'store_data' => [['Read'],['CreateUpdate'],['Delete']], 
            'valueField' => 'action', 
            'value' => 'CreateUpdate', 
            editable: false, 
            'displayField' => 'action', 
            'mode' => 'local', 
            'autoWidth' => true 
          }]
  end

  def callback
    content = {}
    content['Result'] = @datastore['result']
    save content
  end 

end
