require 'time'
require 'rack/utils'
require 'rack/mime'

module Rack
  class File
    def _call(env)
      unless ALLOWED_VERBS.include? env["REQUEST_METHOD"]
        return fail(405, "Method Not Allowed")
      end

      @path_info = Utils.unescape(env["PATH_INFO"])
      parts = @path_info.split SEPS

      parts.inject(0) do |depth, part|
        case part
          when '', '.'
            depth
          when '..'
            return fail(404, "Not Found") if depth - 1 < 0
            depth - 1
          else
            depth + 1
        end
      end

      @path = F.join(@root, *parts)

      available = begin
        F.file?(@path) && F.readable?(@path)
      rescue SystemCallError
        false
      end

      if available
        serving(env)
      else
        # this is the patched line. No need to reflect the URI path, potential XSS
        # exploitable if you can bypass the Content-type: text/plain (IE MHTML and tricks like that)
        fail(404, "File not found")
      end
    end
  end
end