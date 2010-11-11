module BeEF
module UI

#
#
#
class Zombies < BeEF::HttpController
  
  def initialize
    super({
      'paths' => {
        'select_all' => '/select/all/complete.json',
        'select_online' => '/select/online/complete.json',
        'select_offline' => '/select/offline/complete.json',
        
        'select_online_simple' => '/select/online/simple.json',
        'select_all_simple' => '/select/all/simple.json',
        'select_offline_simple' => '/select/offline/simple.json'
      }
    })
  end
  
  # Selects all the zombies and returns them in a JSON array.
  def select_all; @body = zombies2json(BeEF::Models::Zombie.all); end
  
  # Selects all the zombies (IPs only) and returns them in JSON format
  def select_all_simple; @body = zombies2json_simple(BeEF::Models::Zombie.all); end
  
  # Selects all online zombies and returns them in a JSON array.
  def select_online; @body = zombies2json(BeEF::Models::Zombie.all(:lastseen.gte => (Time.new.to_i - 30))); end
  
  # Selects all online zombies (IPs only) and returns them in a JSON array
  def select_online_simple; @body = zombies2json_simple(BeEF::Models::Zombie.all(:lastseen.gte => (Time.new.to_i - 30))); end
  
  # Selects all the offline zombies and returns them in a JSON array.
  def select_offline; @body = zombies2json(BeEF::Models::Zombie.all(:lastseen.lt => (Time.new.to_i - 30))); end
  
  # Selects all the offline zombies (IPs only) and returns them in a JSON array.
  def select_offline_simple; @body = zombies2json_simple(BeEF::Models::Zombie.all(:lastseen.lt => (Time.new.to_i - 30))); end
  
  private
  
  # Takes a list of zombies and format the results in a JSON array.
  def zombies2json(zombies)    
    zombies_hash = {}
    
    zombies.each do |zombie|
      
      # create hash of zombie details
      zombies_hash[zombie.session] = get_hooked_browser_hash(zombie)

    end
    
    zombies_hash.to_json
  end
  
  # Takes a list of zombies and format the results in a JSON array.
  def zombies2json_simple(zombies)
    zombies_hash = {}
    
    zombies.each do |zombie|

      # create hash of zombie details
      zombies_hash[zombie.session] = get_simple_hooked_browser_hash(zombie)

    end

    zombies_hash.to_json
  end
  
  # create a hash of simple hooked browser details
  def get_simple_hooked_browser_hash(hooked_browser)
    
    browser_icon = BeEF::Models::BrowserDetails.browser_icon(hooked_browser.session)
    os_icon = BeEF::Models::BrowserDetails.os_icon(hooked_browser.session)

    return {
      'session' => hooked_browser.session,
      'ip' => hooked_browser.ip,
      'domain' => hooked_browser.domain,
      'browser_icon' => browser_icon,
      'os_icon' => os_icon
    }
    
  end
  
  # create a hash of hooked browser details
  def get_hooked_browser_hash(hooked_browser)
    
    hooked_browser_hash = get_simple_hooked_browser_hash(zombie)
    return hooked_browser_hash.merge( {
      'lastseen' => zombie.lastseen,
      'httpheaders' => JSON.parse(zombie.httpheaders)
    })
        
  end
  
end

end
end