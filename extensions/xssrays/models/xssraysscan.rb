#
# Copyright (c) 2006-2019 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Core
module Models
  #
  # Store the XssRays scans started and finished, with relative ID
  #
  class Xssraysscan < ActiveRecord::Base

    attribute :id, :Serial

    attribute :hooked_browser_id, :Text, :lazy => false

    attribute :scan_start, :DateTime, :lazy => true
    attribute :scan_finish, :DateTime, :lazy => true

    attribute :domain, :Text, :lazy => true
    attribute :cross_domain, :Text, :lazy => true
    attribute :clean_timeout, :Integer, :lazy => false

    attribute :is_started, :Boolean, :lazy => false, :default => false
    attribute :is_finished, :Boolean, :lazy => false, :default => false

    belongs_to :extension_xssrays_details
  end

end
end
end
