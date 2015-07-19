module BeEF
module Extension
module DNSRebinding
module API

    module ServHandler

        BeEF::API::Registrar.instance.register(
                BeEF::Extension::DNSRebinding::API::ServHandler,
                BeEF::API::Server,
                'pre_http_start'
        )

	def self.pre_http_start(http_hook_server)
        config = BeEF::Core::Configuration.instance.get('beef.extension.dns_rebinding')
        address_http = config['address_http_internal']
        address_proxy = config['address_proxy_internal']
        port_http = config['port_http']
        port_proxy = config['port_proxy']
	    Thread.new { BeEF::Extension::DNSRebinding::Server.run_server(address_http, port_http) }
	    Thread.new { BeEF::Extension::DNSRebinding::Proxy.run_server(address_proxy, port_proxy) }
	end

    end
end
end
end
end
