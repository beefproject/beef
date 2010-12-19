module BeEF
module Modules
module Commands


class Detect_cookies < BeEF::Command
  
  def initialize
    super({
      'Name' => 'Detect Cookie Support',
      'Description' => %Q{
        This module will check if the browser allows a cookie with specified name to be set.
        },
      'Category' => 'Recon',
      'Data' => [['name' => 'cookie', 'ui_label' => 'Cookie name', 'value' =>'cookie']],
      'Author' => ['vo'],
      'File' => __FILE__
    })

    set_target({
      'verified_status' =>  VERIFIED_WORKING, 
      'browser_name' =>     ALL
    })

    use 'beef.browser.cookie'
    use_template!
  end
  
  def callback
    content = {}
    content['Has Session Cookies'] = @datastore['has_session_cookies']
    content['Has Persistent Cookies'] = @datastore['has_persistent_cookies']
    content['Cookie Attempted'] = @datastore['cookie'] 
    save content
  end

end


end
end
end