#
# Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Models
      module Dns

        # Represents an individual DNS rule.
        class Rule
          include DataMapper::Resource

          storage_names[:default] = 'extension_dns_rules'

          property :id, String, :key => true
          property :pattern, Object, :required => true
          property :resource, Object, :required => true
          property :response, Object, :required => true
          property :callback, Object, :required => true

          # Hooks the model's "save" event. Generates a rule identifier and callback.
          before :save do |rule|
            rule.callback = validate_response(rule.resource, rule.response)
            rule.id = BeEF::Core::Crypto.dns_rule_id
          end

        private
          # Strict validator which ensures that only an appropriate response is given.
          #
          # @param resource [Resolv::DNS::Resource::IN] resource record type
          # @param response [String, Symbol, Array] response to include in callback
          #
          # @return [String] string representation of callback that can safely be eval'd
          def validate_response(resource, response)
            domain_regex = /^[0-9a-z-]+(\.[0-9a-z-]+)*(\.[a-z]{2,})$/i
            sym_regex = /^:?(NoError|FormErr|ServFail|NXDomain|NotImp|Refused|NotAuth)$/i

            ipv4_regex = /^((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}
              (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])$/x

            ipv6_regex = /^(([0-9a-f]{1,4}:){7,7}[0-9a-f]{1,4}|
              ([0-9a-f]{1,4}:){1,7}:|
              ([0-9a-f]{1,4}:){1,6}:[0-9a-f]{1,4}|
              ([0-9a-f]{1,4}:){1,5}(:[0-9a-f]{1,4}){1,2}|
              ([0-9a-f]{1,4}:){1,4}(:[0-9a-f]{1,4}){1,3}|
              ([0-9a-f]{1,4}:){1,3}(:[0-9a-f]{1,4}){1,4}|
              ([0-9a-f]{1,4}:){1,2}(:[0-9a-f]{1,4}){1,5}|
              [0-9a-f]{1,4}:((:[0-9a-f]{1,4}){1,6})|
              :((:[0-9a-f]{1,4}){1,7}|:)|
              fe80:(:[0-9a-f]{0,4}){0,4}%[0-9a-z]{1,}|
              ::(ffff(:0{1,4}){0,1}:){0,1}
              ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]).){3,3}
              (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|
              ([0-9a-f]{1,4}:){1,4}:
              ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]).){3,3}
              (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$/ix

            begin
              src = if resource == Resolv::DNS::Resource::IN::A
                if response.is_a?(String) && response =~ ipv4_regex
                  sprintf "t.respond!('%s')", response
                elsif (response.is_a?(Symbol) && response.to_s =~ sym_regex) || response =~ sym_regex
                  sprintf "t.fail!(:%s)", response.to_sym
                elsif response.is_a?(Array)
                  str1 = "t.respond!('%s');"
                  str2 = ''

                  response.each do |r|
                    raise InvalidDnsResponseError, 'A' unless r =~ ipv4_regex
                    str2 << sprintf(str1, r)
                  end

                  str2
                else
                  raise InvalidDnsResponseError, 'A'
                end
              elsif resource == Resolv::DNS::Resource::IN::AAAA
                if response.is_a?(String) && response =~ ipv6_regex
                  sprintf "t.respond!('%s')", response
                elsif (response.is_a?(Symbol) && response.to_s =~ sym_regex) || response =~ sym_regex
                  sprintf "t.fail!(:%s)", response.to_sym
                elsif response.is_a?(Array)
                  str1 = "t.respond!('%s');"
                  str2 = ''

                  response.each do |r|
                    raise InvalidDnsResponseError, 'AAAA' unless r =~ ipv6_regex
                    str2 << sprintf(str1, r)
                  end

                  str2
                else
                  raise InvalidDnsResponseError, 'AAAA'
                end
              elsif resource == Resolv::DNS::Resource::IN::CNAME
                if response.is_a?(String) && response =~ domain_regex
                  sprintf "t.respond!(Resolv::DNS::Name.create('%s'))", response
                elsif (response.is_a?(Symbol) && response.to_s =~ sym_regex) || response =~ sym_regex
                  sprintf "t.fail!(:%s)", response.to_sym
                else
                  raise InvalidDnsResponseError, 'CNAME'
                end
              elsif resource == Resolv::DNS::Resource::IN::HINFO
                if response.is_a?(Array)
                  response.each { |r| raise InvalidDnsResponseError, 'HINFO' unless r.is_a?(String) }
                  data = { :cpu => response[0], :os => response[1] }
                  sprintf "t.respond!('%<cpu>s', '%<os>s')", data
                elsif (response.is_a?(Symbol) && response.to_s =~ sym_regex) || response =~ sym_regex
                  sprintf "t.fail!(:%s)", response.to_sym
                else
                  raise InvalidDnsResponseError, 'HINFO'
                end
              elsif resource == Resolv::DNS::Resource::IN::MINFO
                if response.is_a?(Array)
                  response.each { |r| raise InvalidDnsResponseError, 'MINFO' unless r.is_a?(String) && r =~ domain_regex }

                  data = { :rmailbx => response[0], :emailbx => response[1] }

                  sprintf "t.respond!(Resolv::DNS::Name.create('%<rmailbx>s'), " +
                          "Resolv::DNS::Name.create('%<emailbx>s'))",
                          data
                elsif (response.is_a?(Symbol) && response.to_s =~ sym_regex) || response =~ sym_regex
                  sprintf "t.fail!(:%s)", response.to_sym
                else
                  raise InvalidDnsResponseError, 'MINFO'
                end
              elsif resource == Resolv::DNS::Resource::IN::MX
                if response[0].is_a?(Integer) &&
                    response[1].is_a?(String) &&
                    response[1] =~ domain_regex

                  data = { :preference => response[0], :exchange => response[1] }
                  sprintf "t.respond!(%<preference>d, Resolv::DNS::Name.create('%<exchange>s'))", data
                elsif (response.is_a?(Symbol) && response.to_s =~ sym_regex) || response =~ sym_regex
                  sprintf "t.fail!(:%s)", response.to_sym
                else
                  raise InvalidDnsResponseError, 'MX'
                end
              elsif resource == Resolv::DNS::Resource::IN::NS
                if response.is_a?(String) && response =~ domain_regex
                  sprintf "t.respond!(Resolv::DNS::Name.create('%s'))", response
                elsif (response.is_a?(Symbol) && response.to_s =~ sym_regex) || response =~ sym_regex
                  sprintf "t.fail!(:%s)", response.to_sym
                elsif response.is_a?(Array)
                  str1 = "t.respond!(Resolv::DNS::Name.create('%s'))"
                  str2 = ''

                  response.each do |r|
                    raise InvalidDnsResponseError, 'NS' unless r =~ ipv4_regex
                    str2 << sprintf(str1, r)
                  end

                  str2
                else
                  raise InvalidDnsResponseError, 'NS'
                end
              elsif resource == Resolv::DNS::Resource::IN::PTR
                if response.is_a?(String) && response =~ domain_regex
                  sprintf "t.respond!(Resolv::DNS::Name.create('%s'))", response
                elsif (response.is_a?(Symbol) && response.to_s =~ sym_regex) || response =~ sym_regex
                  sprintf "t.fail!(:%s)", response.to_sym
                else
                  raise InvalidDnsResponseError, 'PTR'
                end
              elsif resource == Resolv::DNS::Resource::IN::SOA
                if response.is_a?(Array)
                  unless response[0].is_a?(String) &&
                      response[0] =~ domain_regex &&
                      response[1].is_a?(String) &&
                      response[1] =~ domain_regex &&
                      response[2].is_a?(Integer) &&
                      response[3].is_a?(Integer) &&
                      response[4].is_a?(Integer) &&
                      response[5].is_a?(Integer) &&
                      response[6].is_a?(Integer)

                    raise InvalidDnsResponseError, 'SOA'
                  end

                  data = {
                    :mname   => response[0],
                    :rname   => response[1],
                    :serial  => response[2],
                    :refresh => response[3],
                    :retry   => response[4],
                    :expire  => response[5],
                    :minimum => response[6]
                  }

                  sprintf "t.respond!(Resolv::DNS::Name.create('%<mname>s'), " +
                          "Resolv::DNS::Name.create('%<rname>s'), " +
                          '%<serial>d, ' +
                          '%<refresh>d, ' +
                          '%<retry>d, ' +
                          '%<expire>d, ' +
                          '%<minimum>d)',
                          data
                elsif (response.is_a?(Symbol) && response.to_s =~ sym_regex) || response =~ sym_regex
                  sprintf "t.fail!(:%s)", response.to_sym
                else
                  raise InvalidDnsResponseError, 'SOA'
                end
              elsif resource == Resolv::DNS::Resource::IN::TXT
                if resource.is_a?(String)
                  sprintf "t.respond!('%s')", response
                elsif (response.is_a?(Symbol) && response.to_s =~ sym_regex) || response =~ sym_regex
                  sprintf "t.fail!(:%s)", response.to_sym
                else
                  raise InvalidDnsResponseError, 'TXT'
                end
              elsif resource == Resolv::DNS::Resource::IN::WKS
                if response.is_a?(Array)
                  unless resource[0].is_a?(String) &&
                      resource[0] =~ ipv4_regex &&
                      resource[1].is_a?(Integer) &&
                      resource[2].is_a?(Integer)
                    raise InvalidDnsResponseError, 'WKS' unless resource.is_a?(String)
                  end

                  data = {
                    :address  => response[0],
                    :protocol => response[1],
                    :bitmap   => response[2]
                  }

                  sprintf "t.respond!('%<address>s', %<protocol>d, %<bitmap>d)", data
                elsif (response.is_a?(Symbol) && response.to_s =~ sym_regex) || response =~ sym_regex
                  sprintf "t.fail!(:%s)", response.to_sym
                else
                  raise InvalidDnsResponseError, 'WKS'
                end
              else
                raise UnknownDnsResourceError
              end
            rescue InvalidDnsResponseError, UnknownDnsResourceError => e
              print_error e.message
              throw :halt
            end

            src
          end

          # Raised when a response is not valid for the given DNS resource record.
          class InvalidDnsResponseError < StandardError

            def initialize(message = nil)
              message = sprintf "Invalid response specified for %s resource record", message unless message.nil?
              super(message)
            end

          end

          # Raised when an unknown DNS resource record is given.
          class UnknownDnsResourceError < StandardError

            DEFAULT_MESSAGE = 'Unknown resource record was given'

            def initialize(message = nil)
              super(message || DEFAULT_MESSAGE)
            end

          end

        end

      end
    end
  end
end
