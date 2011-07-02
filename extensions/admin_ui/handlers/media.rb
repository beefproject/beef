#
#   Copyright 2011 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
module BeEF
module Extension
module AdminUI
module Handlers
  
class MediaHandler < WEBrick::HTTPServlet::FileHandler
  
  def do_GET(req, res)
    super

    # set content types
    res.header['content-type']='text/html' # default content type for all pages
    res.header['content-type']='text/javascript' if req.path =~ /.json$/
    res.header['content-type']='text/javascript' if req.path =~ /.js$/
    res.header['content-type']='text/css' if req.path =~ /.css$/
    res.header['content-type']='image/png' if req.path =~ /.png$/
    res.header['content-type']='image/gif' if req.path =~ /.gif$/
    res.header['content-type']='text/xml' if req.path =~ /.xml$/
    
  end

end

end
end
end
end