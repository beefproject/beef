# detect software
#

class Detect_software < BeEF::Core::Command
  
  def post_execute
    content = {}
    content['detect_software'] = @datastore['detect_software']
    save content
  end
  
end
