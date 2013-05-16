#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Core
module Models

  class DNS

    include DataMapper::Resource

    storage_names[:default] = 'extensions_dns'

    property :id, Serial
    property :pattern, Object
    property :block, Text

  end

end
end
end
