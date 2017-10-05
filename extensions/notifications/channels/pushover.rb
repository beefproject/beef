require 'rushover'

module BeEF
module Extension
module Notifications
module Channels

    class Pushover

        def initialize(message)
            @config = BeEF::Core::Configuration.instance

            # Configure the Pushover Client
            client = Rushover::Client.new(@config.get('beef.extension.notifications.pushover.app_key'))

            # Pushover.notification(message: message, title: "BeEF Notification")
            client.notify(@config.get('beef.extension.notifications.pushover.user_key'), message)
        end
    end
end
end
end
end
