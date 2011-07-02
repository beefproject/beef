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
