#
# Copyright (c) 2006-2020 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Core
module Models

  class CommandModule < BeEF::Core::Model
  
    has_many :commands
  
  end
  
end
end
end
