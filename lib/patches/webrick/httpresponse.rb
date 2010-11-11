# The following file contains patches for WEBrick.
module WEBrick
  
  class HTTPResponse

    #
    # set caching headers none
    #
    def set_no_cache()
      @header['ETag'] = nil
      @header['Last-Modified'] = Time.now + 100**4
      @header['Expires'] = Time.now - 100**4
      @header['Cache-Control'] = 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0'
      @header['Pragma'] = 'no-cache'      
    end
    
    #
    # set the cookie in the response
    # Limit: only one set-cookie will be within the response
    #
    def set_cookie(name, value, path = '/', httponly = true, secure = true)
      
      cookie = WEBrick::Cookie.new(name, value)
      cookie.path = path
      cookie.httponly = httponly
      cookie.secure = secure
      
      # add cookie to response header
      @header['Set-Cookie'] = cookie.to_s
    end

    #
    # This patch should prevent leakage of directory listing, access
    # auth errors, etc.
    #   
    def set_error(ex, backtrace=false)

      # set repsonse headers
      @status = 404;
      @header['content-type'] = "text/html; charset=UTF-8"

      # set response content
      @body = ''
      @body << <<-_end_of_html_
      
      <HTML>
      <HEAD>
      <TITLE>No page for you!</TITLE>

      <STYLE type="text/css">
        BODY { font: 8pt/12pt verdana }
        H1 { font: 13pt/15pt verdana }
        H2 { font: 8pt/12pt verdana }
        A:link { color: black; text-decoration: none }
        A:visited { color: black; text-decoration: none }
      </STYLE>

      </HEAD><BODY>
      <TABLE width=500 border=0 cellspacing=10>
      <TR>
      <TD>

      <h1><a href="http://www.bindshell.net/tools/beef/">These aren't the pages you're looking for</a></h1>
      
      </TD>
      </TR>
      </TABLE>
      </BODY>
      </HTML>
      
      _end_of_html_
      
    end
  end
end
