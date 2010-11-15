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
      			'Description' => 'Creates a new discrete pop under window with the beef hook included.',
      			'Category' => 'Persistence',
      			'Author' => 'ethicalhack3r',
	      		'File' => __FILE__,
			      'Target' => { 'browser_name' => BeEF::Constants::Browsers::ALL }
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
