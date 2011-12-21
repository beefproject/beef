# phonegap
#

class Geo_locate < BeEF::Core::Command

   def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content
  end 
  
end
