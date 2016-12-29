#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module WebRTC

      #
      # The http handler that manages the WebRTC signals sent from browsers to other browsers.
      #
      class SignalHandler

        R = BeEF::Core::Models::Rtcsignal
        Z = BeEF::Core::Models::HookedBrowser

        def initialize(data)
          @data = data
          setup()
        end

        def setup()

          # validates the hook token
          beef_hook = @data['beefhook'] || nil
          (print_error "beefhook is null";return) if beef_hook.nil?

          # validates the target hook token
          target_beef_id = @data['results']['targetbeefid'] || nil
          (print_error "targetbeefid is null";return) if target_beef_id.nil?

          # validates the signal
          signal = @data['results']['signal'] || nil
          (print_error "Signal is null";return) if signal.nil?

          # validates that a hooked browser with the beef_hook token exists in the db
          zombie_db = Z.first(:session => beef_hook) || nil
          (print_error "Invalid beefhook id: the hooked browser cannot be found in the database";return) if zombie_db.nil?

          # validates that a target browser with the target_beef_token exists in the db
          target_zombie_db = Z.first(:id => target_beef_id) || nil
          (print_error "Invalid targetbeefid: the target hooked browser cannot be found in the database";return) if target_zombie_db.nil?

          # save the results in the database
          signal = R.new(
            :hooked_browser_id => zombie_db.id,
            :target_hooked_browser_id => target_zombie_db.id,
            :signal => signal
          )
          signal.save

        end
      end

      #
      # The http handler that manages the WebRTC messages sent from browsers.
      #
      class MessengeHandler

        Z = BeEF::Core::Models::HookedBrowser

        def initialize(data)
          @data = data
          setup()
        end

        def setup()
          # validates the hook token
          beef_hook = @data['beefhook'] || nil
          (print_error "beefhook is null";return) if beef_hook.nil?

          # validates the target hook token
          peer_id = @data['results']['peerid'] || nil
          (print_error "peerid is null";return) if peer_id.nil?

          # validates the message
          message = @data['results']['message'] || nil
          (print_error "Message is null";return) if message.nil?

          # validates that a hooked browser with the beef_hook token exists in the db
          zombie_db = Z.first(:session => beef_hook) || nil
          (print_error "Invalid beefhook id: the hooked browser cannot be found in the database";return) if zombie_db.nil?

          # validates that a browser with the peerid exists in the db
          peer_zombie_db = Z.first(:id => peer_id) || nil
          (print_error "Invalid peer_id: the peer hooked browser cannot be found in the database";return) if peer_zombie_db.nil?

          # Writes the event into the BeEF Logger
          BeEF::Core::Logger.instance.register('WebRTC', "Browser:#{zombie_db.id} received message from Browser:#{peer_zombie_db.id}: #{message}")

          # Perform logic depending on message (updating database)
          puts "message = '" + message + "'"
          if (message == "ICE Status: connected")
            # Find existing status message
            stat = BeEF::Core::Models::Rtcstatus.first(:hooked_browser_id => zombie_db.id, :target_hooked_browser_id => peer_zombie_db.id) || nil
            unless stat.nil?
                stat.status = "Connected"
                stat.updated_at = Time.now
                stat.save
            end
            stat2 = BeEF::Core::Models::Rtcstatus.first(:hooked_browser_id => peer_zombie_db.id, :target_hooked_browser_id => zombie_db.id) || nil
            unless stat2.nil?
                stat2.status = "Connected"
                stat2.updated_at = Time.now
                stat2.save
            end
          elsif (message.end_with?("disconnected"))
            stat = BeEF::Core::Models::Rtcstatus.first(:hooked_browser_id => zombie_db.id, :target_hooked_browser_id => peer_zombie_db.id) || nil
            unless stat.nil?
                stat.status = "Disconnected"
                stat.updated_at = Time.now
                stat.save
            end
            stat2 = BeEF::Core::Models::Rtcstatus.first(:hooked_browser_id => peer_zombie_db.id, :target_hooked_browser_id => zombie_db.id) || nil
            unless stat2.nil?
                stat2.status = "Disconnected"
                stat2.updated_at = Time.now
                stat2.save
            end
          elsif (message == "Stayin alive")
            stat = BeEF::Core::Models::Rtcstatus.first(:hooked_browser_id => zombie_db.id, :target_hooked_browser_id => peer_zombie_db.id) || nil
            unless stat.nil?
                stat.status = "Stealthed!!"
                stat.updated_at = Time.now
                stat.save
            end
            stat2 = BeEF::Core::Models::Rtcstatus.first(:hooked_browser_id => peer_zombie_db.id, :target_hooked_browser_id => zombie_db.id) || nil
            unless stat2.nil?
                stat2.status = "Peer-controlled stealth-mode"
                stat2.updated_at = Time.now
                stat2.save
            end
          elsif (message == "Coming out of stealth...")
            stat = BeEF::Core::Models::Rtcstatus.first(:hooked_browser_id => zombie_db.id, :target_hooked_browser_id => peer_zombie_db.id) || nil
            unless stat.nil?
                stat.status = "Connected"
                stat.updated_at = Time.now
                stat.save
            end
            stat2 = BeEF::Core::Models::Rtcstatus.first(:hooked_browser_id => peer_zombie_db.id, :target_hooked_browser_id => zombie_db.id) || nil
            unless stat2.nil?
                stat2.status = "Connected"
                stat2.updated_at = Time.now
                stat2.save
            end
          elsif (message.start_with?("execcmd"))
            mod = /\(\/command\/(.*)\.js\)/.match(message)[1]
            resp = /Result:.(.*)/.match(message)[1]
            stat = BeEF::Core::Models::Rtcmodulestatus.new(:hooked_browser_id => zombie_db.id,
                                                           :target_hooked_browser_id => peer_zombie_db.id,
                                                           :command_module_id => mod,
                                                           :status => resp,
                                                           :created_at => Time.now,
                                                           :updated_at => Time.now)
            stat.save
          end

        end

      end
    end
  end
end
