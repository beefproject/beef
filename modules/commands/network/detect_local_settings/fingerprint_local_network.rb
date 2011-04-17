module BeEF
module Modules
module Commands
#
# Fingerprint local network module
# This module attempts to fingerprint embedded devices within the zombies'
# local network. It does this by loading images on common local network
# IP addresses then matching the image width, height and path to those
# for a known device.
#
# TODO #
#
# Add IPv6 support
# Add HTTPS support
# -  Devices with invalid certs are blocked by IE and FF by default
# Improve stealth
# -  Load images with CSS "background:" CSS to avoid http auth login popups
# Improve speed
# -  Make IP addresses a user-configurable option rather than a hard-coded list
# -  Detect local ip range first - using browser history and/or with java
#    - History theft via CSS history is patched in modern browsers.
#    - Local IP theft with Java is slow and may fail


class Fingerprint_local_network < BeEF::Command
  
  def initialize
    super({
      'Name' => 'Fingerprint local network',
      'Description' => 'Scan common local network IP addresses for embedded devices.',
      'Category' => 'Network',
      'Author' => ['bcoles@gmail.com', 'wade'],
      'File' => __FILE__
    })

    # Doesn't work in FF4 (but works in 3.x)    
    set_target({
        'verified_status' =>  VERIFIED_USER_NOTIFY,
        'browser_name' =>     FF
    })

    set_target({
	'verified_status' =>  VERIFIED_NOT_WORKING,
	'browser_name' =>     O
    })

    set_target({
        'verified_status' =>  VERIFIED_USER_NOTIFY,
        'browser_name' =>     IE
    })
    
    use_template!
  end
  
  def callback
	content = {}
	content['device'] =@datastore['device'] if not @datastore['device'].nil?
	content['url'] = @datastore['url'] if not @datastore['url'].nil?
	if content.empty?
		content['fail'] = 'Did not detect any local network devices'
	end
	save content
  end

end
  
end
end
end

