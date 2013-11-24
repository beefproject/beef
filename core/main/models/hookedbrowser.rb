#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Core
module Models
  #
  #
  #
  class HookedBrowser
  
    include DataMapper::Resource
  
    storage_names[:default] = 'core_hookedbrowsers'
    
    property :id, Serial
    property :session, Text, :lazy => false
    property :ip, Text, :lazy => false
    property :firstseen, String, :length => 15
    property :lastseen, String, :length => 15
    property :httpheaders, Text, :lazy => false
    # @note the domain originating the hook request
    property :domain, Text, :lazy => false
    property :port, Integer, :default => 80
    property :count, Integer, :lazy => false
    property :has_init, Boolean, :default => false
    property :is_proxy, Boolean, :default => false     
    # @note if true the HB is used as a tunneling proxy

    has n, :commands
    has n, :results
    has n, :logs
    #has n, :https
  
    # Increases the count of a zombie
    def count!
      if not self.count.nil? then self.count += 1; else self.count = 1; end
    end
  
    # Returns the icon representing the browser type the hooked browser is using (i.e. Firefox, Internet Explorer)
    # @return [String] String constant containing browser icon path
    def browser_icon
      agent = JSON.parse(self.httpheaders)['user-agent'].to_s || nil
    
      return BeEF::Extension::AdminUI::Constants::Agents::AGENT_UNKNOWN_IMG if agent.nil?
      return BeEF::Extension::AdminUI::Constants::Agents::AGENT_IE_IMG      if agent.include? BeEF::Extension::AdminUI::Constants::Agents::AGENT_IE_UA_STR
      return BeEF::Extension::AdminUI::Constants::Agents::AGENT_FIREFOX_IMG if agent.include? BeEF::Extension::AdminUI::Constants::Agents::AGENT_FIREFOX_UA_STR
      return BeEF::Extension::AdminUI::Constants::Agents::AGENT_MOZILLA_IMG if agent.include? BeEF::Extension::AdminUI::Constants::Agents::AGENT_MOZILLA_UA_STR
      return BeEF::Extension::AdminUI::Constants::Agents::AGENT_SAFARI_IMG  if agent.include? BeEF::Extension::AdminUI::Constants::Agents::AGENT_SAFARI_UA_STR
      return BeEF::Extension::AdminUI::Constants::Agents::AGENT_KONQ_IMG    if agent.include? BeEF::Extension::AdminUI::Constants::Agents::AGENT_KONQ_UA_STR
      return BeEF::Extension::AdminUI::Constants::Agents::AGENT_CHROME_IMG  if agent.include? BeEF::Extension::AdminUI::Constants::Agents::AGENT_CHROME_UA_STR
      return BeEF::Extension::AdminUI::Constants::Agents::AGENT_OPERA_IMG   if agent.include? BeEF::Extension::AdminUI::Constants::Agents::AGENT_OPERA_UA_STR
    
      BeEF::Extension::AdminUI::Constants::Agents::AGENT_UNKNOWN_IMG
    end
  
    # Returns the icon representing the os type the hooked browser is running (i.e. Windows, Linux)
    # @return [String] String constant containing operating system icon path
    def os_icon
      agent = JSON.parse(self.httpheaders)['user-agent'].to_s || nil
    
      return BeEF::Core::Constants::Os::OS_UNKNOWN_IMG if agent.nil?
      return BeEF::Core::Constants::Os::OS_WINDOWS_IMG if agent.include? BeEF::Core::Constants::Os::OS_WINDOWS_UA_STR
      return BeEF::Core::Constants::Os::OS_LINUX_IMG if agent.include? BeEF::Core::Constants::Os::OS_LINUX_UA_STR
      return BeEF::Core::Constants::Os::OS_MAC_IMG if agent.include? BeEF::Core::Constants::Os::OS_MAC_UA_STR
    
      BeEF::Core::Constants::Os::OS_UNKNOWN_IMG
    end
  
  end

end
end
end
