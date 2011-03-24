module BeEF
  
    #
    # Custom FileHandler to deal with tracked files
    #
  class FileHandler < WEBrick::HTTPServlet::FileHandler
  
    #
    # Override to do_GET to check tracked files
    #
    def do_GET(req, res)
        if not BeEF::AssetHandler.instance.check(req.path)
            raise HTPPStatus::NotFound, "`#req.path}` not found."
        else 
            super
        end
    end
    
  end
  
end
