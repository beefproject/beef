# The following file contains patches for WEBrick.

module WEBrick
module HTTPServlet

  class FileHandler
    
    # prevent directory traversal attacks
    def prevent_directory_traversal(req, res)
      raise WEBrick::HTTPStatus::BadRequest, "null character in path" if has_null?(req.path_info)

      if trailing_pathsep?(req.path_info)
        expanded = File.expand_path(req.path_info + "x")
        expanded.chop!  # remove trailing "x"
      else
        expanded = File.expand_path(req.path_info)
      end
      req.path_info = expanded
    end
    
    # checks if a string contains null characters
    def has_null? (str)
      str.split(//).each {|c| 
        return true if c.eql?("\000")
      }
      false
    end
    
  end
  
end
end
