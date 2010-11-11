module BeEF
module Modules
module Commands


class Collect_links < BeEF::Command
  
  def initialize
    super({
      'Name' => 'Collect Links',
      'Description' => %Q{
        This module will retrieve HREFs from the target page
        },
      'Category' => 'Recon',
      'Author' => ['vo'],
      'File' => __FILE__,
      'Target' => {
        'browser_name' =>     BeEF::Constants::Browsers::ALL
      }
    })
    
    use 'beef.dom'
    use_template!
  end
  
  def callback
    content = {}
    content['Links'] = @datastore['links']
    
    save content
  end

end


end
end
end