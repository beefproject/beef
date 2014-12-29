#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

# Disables the logger used by RubyDNS due to its excessive verbosity.
class Logger

  def debug(msg); end
  def info(msg); end
  def error(msg); end
  def warn(msg); end

end
