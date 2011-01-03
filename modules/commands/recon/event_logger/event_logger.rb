module BeEF
module Modules
module Commands


class Event_logger < BeEF::Command
  
  def initialize
    super({
      'Name' => 'Event Logger',
      'Description' => %Q{
        Logs user activity on target browser.
        },
      'Category' => 'Recon',
      'Author' => ['passbe'],
      'File' => __FILE__
    })

    set_target({
      'verified_status' =>  VERIFIED_WORKING, 
      'browser_name' =>     ALL
    })
    
    use 'beef.dom'
    use_template!
  end
  
  def callback
    save({'result' => @datastore['result']})
  end

end


end
end
end