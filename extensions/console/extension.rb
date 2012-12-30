#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module Console

  extend BeEF::API::Extension
  
  #
  # Sets the information for that extension.
  #
  @short_name = @full_name = 'console'
  @description = 'console environment to manage beef'

end
end
end

