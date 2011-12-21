# phonegap
#

class Detect < BeEF::Core::Command
  
  def post_execute
    content = {}
    content['phonegap_version'] = @datastore['phonegap_version']
    save content
  end
  
end
