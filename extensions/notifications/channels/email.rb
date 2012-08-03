#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#
#
require 'net/smtp'

module BeEF
module Extension
module Notifications
module Channels
  
  class Email

    #
    # Constructor
    #
    def initialize(to_address, message)
      @config = BeEF::Core::Configuration.instance
      @from_address       = @config.get('beef.extension.notifications.email.from_address')
      @smtp_host    = @config.get('beef.extension.notifications.email.smtp_host')
      @smtp_port = @config.get('beef.extension.notifications.email.smtp_port')
      @smtp_tls_enable = @config.get('beef.extension.notifications.email.smtp_tls_enable')
      @password = @config.get('beef.extension.notifications.email.smtp_tls_password')

      # configure the email client
      msg = "Subject: BeEF Notification\n\n" + message
      smtp = Net::SMTP.new @smtp_host, @smtp_port
      #if @smtp_tls_enable?
      #  smtp.enable_starttls
      #  smtp.start('beefproject.com', @from_address, @password, :login) do
      #    smtp.send_message(msg, @from_address, @to_address)
      #  end
      #else
        smtp.start do
          smtp.send_message(msg, @from_address, to_address)
        end
      #end

    end

  end
  
end
end
end
end

