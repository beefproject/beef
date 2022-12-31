#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Models
      #
      # Table stores the details of browsers.
      #
      # For example, the type and version of browser the hooked browsers are using.
      #
      class BrowserDetails < BeEF::Core::Model
        #
        # Returns the requested value from the data store
        #
        def self.get(session_id, key)
          browserdetail = where(session_id: session_id, detail_key: key).first

          return nil if browserdetail.nil?
          return nil if browserdetail.detail_value.nil?

          browserdetail.detail_value
        end

        #
        # Stores or updates an existing key->value pair in the data store
        #
        def self.set(session_id, detail_key, detail_value)
          browserdetails = BeEF::Core::Models::BrowserDetails.where(
            session_id: session_id,
            detail_key: detail_key
          ).first
          if browserdetails.nil?
            # store the new browser details key/value
            browserdetails = BeEF::Core::Models::BrowserDetails.new(
              session_id: session_id,
              detail_key: detail_key,
              detail_value: detail_value || ''
            )
            result = browserdetails.save!
          else
            # update the browser details key/value
            browserdetails.detail_value = detail_value || ''
            result = browserdetails.save!
            print_debug "Browser has updated '#{detail_key}' to '#{detail_value}'"
          end

          # if the attempt to save the browser details fails return a bad request
          print_error "Failed to save browser details: #{detail_key}=#{detail_value}" if result.nil?

          browserdetails
        end
      end
    end
  end
end
