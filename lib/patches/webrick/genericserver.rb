# The following file contains patches for WEBrick.
module WEBrick
  
  class HTTPServer < ::WEBrick::GenericServer
    
    # I'm patching WEBrick so it does not log http requests anymore.
    # The reason being that it seems to considerably slow down BeEF which receives
    # numerous requests simultaneously. Additionally, it was also found to crash
    # the thread when not being able to write to the log file (which happened when
    # overloaded).
    def access_log(config, req, res); return; end
    
  end
  
end