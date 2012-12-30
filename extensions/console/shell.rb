#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'rex'
require 'rex/ui'

module BeEF
module Extension
module Console

class Shell
  
  DefaultPrompt     = "%undBeEF%clr"
  DefaultPromptChar = "%clr>"
  
  include Rex::Ui::Text::DispatcherShell
  
  def initialize(prompt = DefaultPrompt, prompt_char = DefaultPromptChar, opts = {})
    
    require 'extensions/console/lib/readline_compatible'
    require 'extensions/console/lib/command_dispatcher'
    require 'extensions/console/lib/shellinterface'
    
    self.http_hook_server = opts['http_hook_server']
    self.config = opts['config']
    self.jobs = Rex::JobContainer.new
    self.interface = BeEF::Extension::Console::ShellInterface.new(self.config)
    
    super(prompt, prompt_char, File.expand_path(self.config.get("beef.extension.console.shell.historyfolder").to_s + self.config.get("beef.extension.console.shell.historyfile").to_s))
    
    input = Rex::Ui::Text::Input::Stdio.new
    output = Rex::Ui::Text::Output::Stdio.new
    
    init_ui(input,output)
    
    enstack_dispatcher(CommandDispatcher::Core)
    
    #To prevent http_hook_server from blocking, we kick it off as a background job here.
    self.jobs.start_bg_job(
      "http_hook_server",
      self,
      Proc.new { |ctx_| self.http_hook_server.start }
    )
    
  end
  
  def stop
    super
  end
  
  #New method to determine if a particular command dispatcher it already .. enstacked .. gooood
	def dispatched_enstacked(dispatcher)
	  inst = dispatcher.new(self)
	  self.dispatcher_stack.each { |disp|
	    if (disp.name == inst.name)
	      return true
      end
    }
    return false
  end
  
  attr_accessor :http_hook_server
  attr_accessor :config
  attr_accessor :jobs
  attr_accessor :interface
  
end

end end end