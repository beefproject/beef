#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Core
module Models
  #
  # Store the XssRays scans started and finished, with relative ID
  #
  class Xssraysscan

    include DataMapper::Resource

    storage_names[:default] = 'extension_xssrays_scans'

    property :id, Serial

    property :hooked_browser_id, Text, :lazy => false

    property :scan_start, DateTime, :lazy => true
    property :scan_finish, DateTime, :lazy => true

    property :domain, Text, :lazy => true
    property :cross_domain, Text, :lazy => true
    property :clean_timeout, Integer, :lazy => false

    property :is_started, Boolean, :lazy => false, :default => false
    property :is_finished, Boolean, :lazy => false, :default => false

    has n, :extension_xssrays_details, 'Xssraysdetail'

  end

end
end
end
