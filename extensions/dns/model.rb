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

    property :name,  String
    property :type,  String
    property :value, String

    property :id, Serial, :key => true

  end

end
end
end
