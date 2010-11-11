module BeEF
module Modules
module Commands

class Detect_tor < BeEF::Command
  
  def initialize
    super({
      'Name' => 'Detect Tor',
      'Description' => 'This module will detect if the zombie is currently using TOR (The Onion Router).',
      'Category' => 'Recon',
      'Author' => ['pdp', 'wade', 'bm', 'xntrik'],
      'Data' =>
          [
              ['name'=>'timeout', 'ui_label' =>'Detection timeout','value'=>'10000']
          ],
      'File' => __FILE__,
      'Target' => {
            'browser_name' =>     BeEF::Constants::Browsers::ALL
      }
    })
    
    use 'beef.net.local'
    
    use_template!
  end
  
  def callback
    return if @datastore['result'].nil?
    
    save({'result' => @datastore['result']})
  end
  
end

end
end
end
