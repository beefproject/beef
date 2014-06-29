#
# Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Test_dns_tunnel_client < BeEF::Core::Command
  
  def self.options
	@configuration = BeEF::Core::Configuration.instance

    return [
        {'name' => 'domain', 'ui_label'=>'Domain', 'type' => 'text', 'width' => '400px', 'value' => 'browserhacker.com' },
		    {'name' => 'data', 'ui_label'=>'Data to send', 'type' => 'textarea', 'value' =>
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras rutrum fermentum nunc, vel varius libero pharetra a. Duis rhoncus nisi volutpat elit suscipit auctor. In fringilla est eget tortor bibendum gravida. Pellentesque aliquet augue libero, at gravida arcu. Nunc et quam sapien, eu pulvinar erat. Quisque dignissim imperdiet neque, et interdum sem sagittis a. Maecenas non mi elit, a luctus neque. Nam pulvinar libero sit amet dui suscipit facilisis. Duis sed mauris elit. Aliquam cursus scelerisque diam a fringilla. Curabitur mollis nisi in ante hendrerit pellentesque ut ac orci. In congue nunc vitae enim pharetra eleifend.',
             'width' => '400px', 'height' => '300px'
        }
    ]
  end
  
  def post_execute
    content = {}
    content['dns_requests'] = @datastore['dns_requests']
    save content
  end
  
end
