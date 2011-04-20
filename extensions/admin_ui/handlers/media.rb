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