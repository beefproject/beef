#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# Phonegap_prompt_user
#

class Phonegap_alert_user < BeEF::Core::Command
  
    def self.options
        return [{
            'name' => 'title', 
            'description' => 'Alert title', 
            'ui_label'=>'Title', 
            'value' => 'Beef',
            'width' => '300px'
            },{
            'name' => 'message', 
            'description' => 'Message', 
            'ui_label'=>'Message', 
            'value' => 'Game over!',
            'width' => '300px'
            },{
            'name' => 'buttonName',
            'description' => 'Default button name',
            'ui_label'=>'Button name',
            'value' => 'Done',
            'width' => '100px'
            }]
  end

  def callback
    content = {}
    content['Result'] = @datastore['result']
    save content
  end 

end
