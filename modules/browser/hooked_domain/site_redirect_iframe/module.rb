#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Site_redirect_iframe < BeEF::Core::Command
  
    def self.options
		configuration = BeEF::Core::Configuration.instance
		favicon_uri = "http://#{configuration.get("beef.http.host")}:#{configuration.get("beef.http.port")}/ui/media/images/favicon.ico"
        return [
			  { 'name' => 'iframe_title', 'description' => 'Title of the iFrame', 'ui_label' => 'New Title', 'value' => 'BeEF - The Browser Exploitation Framework Project', 'width'=>'200px' },
			  { 'name' => 'iframe_favicon', 'description' => 'Shortcut Icon', 'ui_label' => 'New Favicon', 'value' => favicon_uri, 'width'=>'200px' },

			  { 'name' => 'iframe_src', 'description' => 'Source of the iFrame', 'ui_label' => 'Redirect URL', 'value' => 'http://beefproject.com/', 'width'=>'200px' },
			  { 'name' => 'iframe_timeout', 'description' => 'iFrame timeout', 'ui_label' => 'Timeout', 'value' => '3500', 'width'=>'150px' }
        ]
    end

  # This method is being called when a hooked browser sends some
  # data back to the framework.
  #
  def post_execute
    save({'result' => @datastore['result']})
  end
  
end
