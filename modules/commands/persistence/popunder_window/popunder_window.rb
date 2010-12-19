module BeEF
module Modules
module Commands


class Popunder_window < BeEF::Command
  
  	#
  	# Defines and set up the commmand module.
  	#
	def initialize
		super({
      'Name' => 'Pop Under Window',
      'Description' => 'Creates a new discrete pop under window with the beef hook included.<br><br>This module will add another browser node to the tree. It will be a duplicate. This will be addressed in a future release',
      'Category' => 'Persistence',
      'Author' => 'ethicalhack3r',
	    'File' => __FILE__
    })

    set_target({
      'verified_status' =>  VERIFIED_WORKING, 
      'browser_name' =>     ALL
    })
   
    use_template!
    
	end

  	# This method is being called when a hooked browser sends some
  	# data back to the framework.
  	#
  	def callback
    		save({'result' => @datastore['result']})
  	end
  
end

end
end
end
