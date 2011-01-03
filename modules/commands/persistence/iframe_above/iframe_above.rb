module BeEF
module Modules
module Commands


class Iframe_above < BeEF::Command
  
  	#
  	# Defines and set up the commmand module.
  	#
	def initialize
		super({
      'Name' => 'iFrame Persistance',
      'Description' => 'Rewrites all links on the webpage to spawn a 100% by 100% iFrame with a source relative to the selected link.',
      'Category' => 'Persistence',
      'Author' => 'passbe',
	    'File' => __FILE__
    })

    set_target({
      'verified_status' =>  VERIFIED_USER_NOTIFY, 
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
