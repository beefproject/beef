#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'slack-notifier'

module BeEF
  module Extension
    module Notifications
      module Channels
        class SlackWorkspace
          def initialize(message)
            @config = BeEF::Core::Configuration.instance

            # Configure the Slack Client
            webhook_url = @config.get('beef.extension.notifications.slack.webhook_url')
            channel = @config.get('beef.extension.notifications.slack.channel')
            username = @config.get('beef.extension.notifications.slack.username')

            if webhook_url.include?('your_webhook_url') || !webhook_url.start_with?('https://hooks.slack.com/services/')
              print_error('[Notifications] Invalid Slack WebHook URL')
              return
            end

            notifier = Slack::Notifier.new(
              webhook_url,
              channel: channel,
              username: username,
              http_options: { open_timeout: 10 }
            )

            notifier.ping message

            print_debug("[Notifications] Established Slack notification channel: #{webhook_url}")
          rescue StandardError => e
            print_error "[Notifications] Slack notification initialization failed: #{e.message}"
          end
        end
      end
    end
  end
end
