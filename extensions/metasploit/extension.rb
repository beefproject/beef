#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Metasploit
      extend BeEF::API::Extension

      @short_name = 'msf'
      @full_name = 'Metasploit'
      @description = 'Metasploit integration'

      # Translates msf exploit options to beef options array
      def self.translate_options(msf_options)
        callback_host = BeEF::Core::Configuration.instance.get('beef.extension.metasploit.callback_host')

        options = []
        msf_options.each do |k, v|
          next if v['advanced'] == true
          next if v['evasion'] == true

          v['allowBlank'] = 'true' if v['required'] == false

          case v['type']
          when 'string', 'address', 'port', 'integer'
            v['type'] = 'text'
            v['value'] = if k == 'URIPATH'
                           rand(3**20).to_s(16)
                         elsif k == 'LHOST'
                           callback_host
                         else
                           v['default']
                         end
          when 'bool'
            v['type'] = 'checkbox'
          when 'enum'
            v['type'] = 'combobox'
            v['store_type'] = 'arraystore',
                              v['store_fields'] = ['enum'],
                              v['store_data'] = translate_enums(v['enums']),
                              v['value'] = v['default']
            v['valueField'] = 'enum',
                              v['displayField'] = 'enum',
                              v['autoWidth'] = true,
                              v['mode'] = 'local'
          end
          v['name'] = k
          v['label'] = k
          options << v
        end

        options
      end

      # Translates msf payloads to a beef compatible drop down
      def self.translate_payload(payloads)
        return unless payloads.key?('payloads')

        values = translate_enums(payloads['payloads'])

        default_payload = values.include?('generic/shell_bind_tcp') ? 'generic/shell_bind_tcp' : values.first

        return unless values.length.positive?

        {
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
          'defaultPayload' => default_payload,
          'reloadOnChange' => true
        }
      end

      # Translates metasploit enums to ExtJS combobox store_data
      def self.translate_enums(enums)
        enums.map { |e| [e] }
      end
    end
  end
end

require 'msfrpc-client'
require 'extensions/metasploit/rpcclient'
require 'extensions/metasploit/api'
require 'extensions/metasploit/module'
require 'extensions/metasploit/rest/msf'
