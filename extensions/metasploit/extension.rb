#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module Metasploit
  
  extend BeEF::API::Extension

  # Translates msf exploit options to beef options array
  def self.translate_options(msf_options)
    options = []
    msf_options.each{|k,v|
	next if v['advanced'] == true || v['evasion'] == true
	v['allowBlank'] = 'true' if v['required'] == false
        case v['type']
            when "string", "address", "port", "integer"
                v['type'] = 'text'
		v['value'] = rand(3**20).to_s(16) if k == 'URIPATH'
		v['value'] = v['default'] if k != "URIPATH"
        	v['value']  =  BeEF::Core::Configuration.instance.get('beef.extension.metasploit.callback_host') if k == "LHOST"

		
            when "bool"
                v['type'] = 'checkbox'
            when "enum"
                v['type'] = 'combobox'
                v['store_type'] = 'arraystore',
                v['store_fields'] = ['enum'],
                v['store_data'] = self.translate_enums(v['enums']),
		v['value'] = v['default']
                v['valueField'] = 'enum',
                v['displayField'] = 'enum',
                v['autoWidth'] = true,
                v['mode'] = 'local'
        end
        v['name'] = k
        v['label'] = k
        options << v
    }
    return options
  end

  # Translates msf payloads to a beef compatible drop down
  def self.translate_payload(payloads)
    if payloads.has_key?('payloads')
       values = self.translate_enums(payloads['payloads'])

       defaultPayload = values[0]
       defaultPayload = 'generic/shell_bind_tcp' if values.include? 'generic/shell_bind_tcp'

       if values.length > 0
           return { 
                'name' => 'PAYLOAD', 
                'type' => 'combobox', 
                'ui_label' => 'Payload', 
                'store_type' => 'arraystore',
                'store_fields' => ['payload'], 
                'store_data' => values,
                'valueField' => 'payload', 
                'displayField' => 'payload', 
                'mode' => 'local', 
                'autoWidth' => true,
		'defaultPayload' => defaultPayload,
		'reloadOnChange' => true
          }
      end
    end
    return nil
  end

  # Translates metasploit enums to ExtJS combobox store_data
  def self.translate_enums(enums)
       values = []
       enums.each{|e|
            values << [e]
       }
       return values
  end
  
  
end
end
end

require 'msfrpc-client'
require 'extensions/metasploit/rpcclient'
require 'extensions/metasploit/api'
require 'extensions/metasploit/module'
