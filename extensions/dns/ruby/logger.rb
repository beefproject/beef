#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

# Overrives the logger used by RubyDNS to use BeEF's print_info() and friends
class Logger

  def debug(msg)
    print_debug "DNS Server: #{msg}"
  end

  def info(msg)
    print_info "DNS Server: #{msg}"
  end

  def error(msg)
    print_error "DNS Server: #{msg}"
  end

end

