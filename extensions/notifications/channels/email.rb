#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
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

