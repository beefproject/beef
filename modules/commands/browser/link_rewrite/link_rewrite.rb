module BeEF
module Modules
module Commands

class Link_rewrite < BeEF::Command
  
  def initialize
    super({
      'Name' => 'Link Rewriter',
      'Description' => 'This module will rewrite the href attribute of all matched links.<br /><br />The jQuery selector field can be used to limit the selection of links. eg: a[href="http://www.bindshell.net"]. For more information please see: http://api.jquery.com/category/selectors/',
      'Category' => 'Browser',
      'Author' => ['passbe'],
      'Data' => [
        ['ui_label'=>'URL', 'name'=>'url', 'value'=>'http://www.bindshell.net/', 'width'=>'200px'],
        ['ui_label'=>'jQuery Selector', 'name'=>'selector', 'value'=>'a', 'width'=>'200px']
      ],
      'File' => __FILE__
    })
    
    set_target({
      'verified_status' =>  VERIFIED_WORKING, 
      'browser_name' =>     ALL
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