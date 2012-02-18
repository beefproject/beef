# phonegap
#

class Phonegap_beep < BeEF::Core::Command

   def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content
  end 
  
end
