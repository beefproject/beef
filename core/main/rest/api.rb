#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Rest

      #
      # Check the source IP is within the permitted subnet
      # This is from extensions/admin_ui/controllers/authentication/authentication.rb
      # TODO FIX THIS
      def self.permitted_source?(ip)
        # get permitted subnet 
        permitted_ui_subnet = BeEF::Core::Configuration.instance.get("beef.restrictions.permitted_ui_subnet")
        target_network = IPAddr.new(permitted_ui_subnet)

        # test if supplied IP address is valid dot-decimal format
        return false unless ip =~ /\A[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\z/

        # test if ip within subnet
        return target_network.include?(ip)
      end

    end
  end
end
