#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Core
module Models
  #
  # Table stores the details of browsers.
  #
  # For example, the type and version of browser the hooked browsers are using.
  #
  class BrowserDetails
  
    include DataMapper::Resource
    
    storage_names[:default] = 'core_browserdetails'
    property :session_id, String, :length => 255, :key => true
    property :detail_key, String, :length => 255, :lazy => false, :key => true
    property :detail_value, Text, :lazy => false  
     
    #
    # Returns the requested value from the data store
    #
    def self.get(session_id, key) 
      browserdetail = first(:session_id => session_id, :detail_key => key)
      
      return nil if browserdetail.nil?
      return nil if browserdetail.detail_value.nil?
      return browserdetail.detail_value
    end
  
    #
    # Stores a key->value pair into the data store
    #
    def self.set(session_id, detail_key, detail_value) 
      # if the details already exist don't re-add them
      return nil if not get(session_id, detail_key).nil?
    
      # store the returned browser details
      browserdetails = BeEF::Core::Models::BrowserDetails.new(
              :session_id => session_id,
              :detail_key => detail_key,
              :detail_value => detail_value)

      result = browserdetails.save
      # if the attempt to save the browser details fails return a bad request
      if result.nil?
        print_error  "Failed to save browser details"
      end
    
      browserdetails
    end
 
    #
    # Returns the icon representing the browser type the
    # hooked browser is using (i.e. Firefox, Internet Explorer)
    #
    def self.browser_icon(session_id)
    
      browser = get(session_id, 'BrowserName')
    
      return BeEF::Extension::AdminUI::Constants::Agents::AGENT_IE_IMG      if browser.eql? 'IE' # Internet Explorer
      return BeEF::Extension::AdminUI::Constants::Agents::AGENT_FIREFOX_IMG if browser.eql? 'FF' # Firefox
      return BeEF::Extension::AdminUI::Constants::Agents::AGENT_SAFARI_IMG  if browser.eql? 'S'  # Safari
      return BeEF::Extension::AdminUI::Constants::Agents::AGENT_CHROME_IMG  if browser.eql? 'C'  # Chrome
      return BeEF::Extension::AdminUI::Constants::Agents::AGENT_OPERA_IMG   if browser.eql? 'O'  # Opera
    
      BeEF::Extension::AdminUI::Constants::Agents::AGENT_UNKNOWN_IMG
    end
  
    #
    # Returns the icon representing the os type the
    # zombie is running (i.e. Windows, Linux)
    #
    def self.os_icon(session_id)

      ua_string = get(session_id, 'BrowserReportedName')
      
      return BeEF::Core::Constants::Os::OS_UNKNOWN_IMG if ua_string.nil?
      return BeEF::Core::Constants::Os::OS_WINDOWS_IMG if ua_string.include? BeEF::Core::Constants::Os::OS_WINDOWS_UA_STR
      return BeEF::Core::Constants::Os::OS_LINUX_IMG if ua_string.include? BeEF::Core::Constants::Os::OS_LINUX_UA_STR
      return BeEF::Core::Constants::Os::OS_QNX_IMG if ua_string.include? BeEF::Core::Constants::Os::OS_QNX_UA_STR
      return BeEF::Core::Constants::Os::OS_BEOS_IMG if ua_string.include? BeEF::Core::Constants::Os::OS_BEOS_UA_STR
      return BeEF::Core::Constants::Os::OS_OPENBSD_IMG if ua_string.include? BeEF::Core::Constants::Os::OS_OPENBSD_UA_STR
      return BeEF::Core::Constants::Os::OS_WEBOS_IMG if ua_string.include? BeEF::Core::Constants::Os::OS_WEBOS_UA_STR
      return BeEF::Core::Constants::Os::OS_IOS_IMG if ua_string.include? BeEF::Core::Constants::Os::OS_IPHONE_UA_STR
      return BeEF::Core::Constants::Os::OS_IOS_IMG if ua_string.include? BeEF::Core::Constants::Os::OS_IPAD_UA_STR
      return BeEF::Core::Constants::Os::OS_IOS_IMG if ua_string.include? BeEF::Core::Constants::Os::OS_IPOD_UA_STR
      return BeEF::Core::Constants::Os::OS_MAEMO_IMG if ua_string.include? BeEF::Core::Constants::Os::OS_MAEMO_UA_STR
      return BeEF::Core::Constants::Os::OS_MAC_IMG if ua_string.include? BeEF::Core::Constants::Os::OS_MAC_UA_STR
      return BeEF::Core::Constants::Os::OS_BLACKBERRY_IMG if ua_string.include? BeEF::Core::Constants::Os::OS_BLACKBERRY_UA_STR
      return BeEF::Core::Constants::Os::OS_ANDROID_IMG if ua_string.include? BeEF::Core::Constants::Os::OS_ANDROID_UA_STR
    
      BeEF::Core::Constants::Os::OS_UNKNOWN_IMG
    end
  
    #
    # Returns the icon representing the hardware the
    # zombie is running on (i.e. iPhone, BlackBerry)
    #
    def self.hw_icon(session_id)

      ua_string = get(session_id, 'BrowserReportedName')
      hardware  = get(session_id, 'Hardware')
      return BeEF::Core::Constants::Hardware::HW_VM_IMG if hardware =~ /Virtual Machine/
      return BeEF::Core::Constants::Hardware::HW_LAPTOP_IMG if hardware =~ /Laptop/
      return BeEF::Core::Constants::Hardware::HW_UNKNOWN_IMG if ua_string.nil?

      return BeEF::Core::Constants::Hardware::HW_WINPHONE_IMG if ua_string.include? BeEF::Core::Constants::Hardware::HW_WINPHONE_UA_STR
      return BeEF::Core::Constants::Hardware::HW_ZUNE_IMG if ua_string.include? BeEF::Core::Constants::Hardware::HW_ZUNE_UA_STR
      return BeEF::Core::Constants::Hardware::HW_BLACKBERRY_IMG if ua_string.include? BeEF::Core::Constants::Hardware::HW_BLACKBERRY_UA_STR
      return BeEF::Core::Constants::Hardware::HW_IPHONE_IMG if ua_string.include? BeEF::Core::Constants::Hardware::HW_IPHONE_UA_STR
      return BeEF::Core::Constants::Hardware::HW_IPAD_IMG if ua_string.include? BeEF::Core::Constants::Hardware::HW_IPAD_UA_STR
      return BeEF::Core::Constants::Hardware::HW_IPOD_IMG if ua_string.include? BeEF::Core::Constants::Hardware::HW_IPOD_UA_STR
      return BeEF::Core::Constants::Hardware::HW_KINDLE_IMG if ua_string.include? BeEF::Core::Constants::Hardware::HW_KINDLE_UA_STR
      return BeEF::Core::Constants::Hardware::HW_NOKIA_IMG if ua_string.include? BeEF::Core::Constants::Hardware::HW_NOKIA_UA_STR
      return BeEF::Core::Constants::Hardware::HW_MOTOROLA_IMG if ua_string.include? BeEF::Core::Constants::Hardware::HW_MOTOROLA_UA_STR
      return BeEF::Core::Constants::Hardware::HW_HTC_IMG if ua_string.include? BeEF::Core::Constants::Hardware::HW_HTC_UA_STR
      return BeEF::Core::Constants::Hardware::HW_GOOGLE_IMG if ua_string.include? BeEF::Core::Constants::Hardware::HW_GOOGLE_UA_STR
	return BeEF::Core::Constants::Hardware::HW_ERICSSON_IMG if ua_string.include? BeEF::Core::Constants::Hardware::HW_ERICSSON_UA_STR

      BeEF::Core::Constants::Hardware::HW_UNKNOWN_IMG

    end

  end

end
end
end
