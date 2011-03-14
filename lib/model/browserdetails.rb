module BeEF
module Models

class BrowserDetails
  
  include DataMapper::Resource
  
  attr_reader :guard
  
  #
  # Class constructor
  #
  def initialize(config)
    # we set up a mutex
    super(config)
    @@guard = Mutex.new
  end
  
  storage_names[:default] = 'browser_details'
  
  property :session_id, Text, :key => true
  property :detail_key, Text, :lazy => false, :key => true
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
    browserdetails = BeEF::Models::BrowserDetails.new(
            :session_id => session_id,
            :detail_key => detail_key,
            :detail_value => detail_value)

    @@guard.synchronize {
      result = browserdetails.save
      # if the attempt to save the browser details fails return a bad request
      raise WEBrick::HTTPStatus::BadRequest, "Failed to save browser details" if result.nil?    
    }
    
    browserdetails
  end
  
  #
  # Returns the icon representing the browser type the
  # hooked browser is using (i.e. Firefox, Internet Explorer)
  #
  def self.browser_icon(session_id)
    
    browser = get(session_id, 'BrowserName')
    
    return BeEF::Constants::Agents::AGENT_IE_IMG      if browser.eql? "IE" # Internet Explorer
    return BeEF::Constants::Agents::AGENT_FIREFOX_IMG if browser.eql? "FF" # Firefox
    return BeEF::Constants::Agents::AGENT_SAFARI_IMG  if browser.eql? "S"  # Safari
    return BeEF::Constants::Agents::AGENT_CHROME_IMG  if browser.eql? "C"  # Chrome
    return BeEF::Constants::Agents::AGENT_OPERA_IMG   if browser.eql? "O"  # Opera
    
    BeEF::Constants::Agents::AGENT_UNKNOWN_IMG
  end
  
  #
  # Returns the icon representing the os type the
  # zombie is running (i.e. Windows, Linux)
  #
  def self.os_icon(session_id)

    ua_string = get(session_id, 'BrowserReportedName')

    return BeEF::Constants::Os::OS_UNKNOWN_IMG if ua_string.nil? # Unknown
    return BeEF::Constants::Os::OS_WINDOWS_IMG if ua_string.include? BeEF::Constants::Os::OS_WINDOWS_UA_STR # Windows
    return BeEF::Constants::Os::OS_LINUX_IMG if ua_string.include? BeEF::Constants::Os::OS_LINUX_UA_STR     # Linux
    return BeEF::Constants::Os::OS_IPHONE_IMG if ua_string.include? BeEF::Constants::Os::OS_IPHONE_UA_STR    # iPhone - do this before Mac, because it includes Mac
    return BeEF::Constants::Os::OS_MAC_IMG if ua_string.include? BeEF::Constants::Os::OS_MAC_UA_STR         # Mac OS X
    
    BeEF::Constants::Os::OS_UNKNOWN_IMG
  end
  
end

end
end
