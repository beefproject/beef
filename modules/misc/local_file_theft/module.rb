# local_file_theft
#
# Shamelessly plagurised from kos.io/xsspwn

class Local_file_theft < BeEF::Core::Command

   def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content
  end 
  
end
