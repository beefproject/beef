#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Alert_dialog < BeEF::Core::Command
  
 # set and return all options for this module
  def self.options
    return [{
      'name' => 'text', 
      'description' => 'Sends an alert dialog to the victim', 
      'type' => 'textarea',
      'ui_label' => 'Alert text',
      'value' => 'BeEF Alert Dialog',
      'width' => '400px' 
      }]
  end

  def post_execute 
    content = {}
    content['User Response'] = "The user clicked the 'OK' button when presented with an alert box."
    save content
  end
  
end
