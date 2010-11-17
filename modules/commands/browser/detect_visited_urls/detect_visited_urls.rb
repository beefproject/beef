module BeEF
module Modules
module Commands

class Detect_visited_urls < BeEF::Command
  
  def initialize
    super({
      'Name' => 'Detect Visited URLs',
      'Description' => 'This module will detect whether or not the zombie has visited the specifed URL(s) before.',
      'Category' => 'Browser',
      'Author' => ['passbe'],
      'Data' => [
        ['ui_label'=>'URL(s)', 'name'=>'urls', 'type'=>'textarea', 'value'=>'http://www.bindshell.net/', 'width'=>'200px']
      ],
      'File' => __FILE__,
      'Target' => {
        'browser_name' =>     BeEF::Constants::Browsers::ALL
      }
    })    
              
    use_template!
  end

  def callback
    save({'result' => @datastore['result']})
  end
  
end

end
end
end