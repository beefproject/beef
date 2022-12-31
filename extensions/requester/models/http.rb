#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Models
      #
      # Table stores the http requests and responses from the requester.
      #
      class Http < BeEF::Core::Model
        #
        # Removes a request/response from the data store
        #
        def self.delete(id)
          if id.to_s !~ /\A\d+\z/
            (print_error 'Failed to remove response. Invalid response ID.'
             return)
          end
          r = BeEF::Core::Models::Http.find(id.to_i)
          if r.nil?
            (print_error "Failed to remove response [id: #{id}]. Response does not exist."
             return)
          end
          r.destroy
        end
      end
    end
  end
end
