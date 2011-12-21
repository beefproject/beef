# phonegap
#

class Detect < BeEF::Core::Command
  
  def post_execute
    content = {}
    content['phonegap'] = @datastore['phonegap']
    save content
  end
  
end
