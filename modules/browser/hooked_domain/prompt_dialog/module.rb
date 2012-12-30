#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Prompt_dialog < BeEF::Core::Command
  
  def self.options
    return [
        {'name' =>'question', 'description' =>'Prompt text', 'ui_label'=>'Prompt text'}
    ]
  end
  
  #
  # This method is being called when a zombie sends some
  # data back to the framework.
  #
  def post_execute
    
#    return if @datastore['answer']==''

    save({'answer' => @datastore['answer']})
  end
  
end
