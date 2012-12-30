#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module API
module NetworkStack
module Handlers
module AssetHandler

    # Binds a file to be accessible by the hooked browser
    # @param [String] file file to be served
    # @param [String] path URL path to be bound, if no path is specified a randomly generated one will be used
    # @param [String] extension to be used in the URL
    # @param [Integer] count amount of times the file can be accessed before being automatically unbound. (-1 = no limit)
    # @return [String] URL bound to the specified file
    # @todo Add hooked browser parameter to only allow specified hooked browsers access to the bound URL. Waiting on Issue #336
    # @note This is a direct API call and does not have to be registered to be used
    def self.bind(file, path=nil, extension=nil, count=-1)
        return BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind(file, path, extension, count)
    end

    # Unbinds a file made accessible to hooked browsers
    # @param [String] url the bound URL
    # @todo Add hooked browser parameter to only unbind specified hooked browsers binds. Waiting on Issue #336
    # @note This is a direct API call and does not have to be registered to be used
    def self.unbind(url)
        BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind(url)
    end

end
end
end
end
end
