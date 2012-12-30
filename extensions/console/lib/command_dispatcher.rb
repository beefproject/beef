#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module Console

module CommandDispatcher
  include Rex::Ui::Text::DispatcherShell::CommandDispatcher
  
  def initialize(driver)
    super
    
    self.driver = driver
  end
  
  attr_accessor :driver
  
end

end end end

require 'extensions/console/lib/command_dispatcher/core'
require 'extensions/console/lib/command_dispatcher/target'
require 'extensions/console/lib/command_dispatcher/command'