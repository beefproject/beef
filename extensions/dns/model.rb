#
# Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
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

          # Hooks the model's "save" event. Validates pattern/response and generates a rule identifier.
          before :save do |rule|
            begin
              validate_pattern(rule.pattern)
              rule.callback = format_callback(rule.resource, rule.response)
            rescue InvalidDnsPatternError, UnknownDnsResourceError, InvalidDnsResponseError => e
              print_error e.message
              throw :halt
            end

            rule.id = BeEF::Core::Crypto.dns_rule_id
          end

        private
          # Verifies that the given pattern is valid (i.e. non-empty, no null's or printable characters).
          def validate_pattern(pattern)
            raise InvalidDnsPatternError unless BeEF::Filters.is_non_empty_string?(pattern) &&
              !BeEF::Filters.has_null?(pattern) &&
              !BeEF::Filters.has_non_printable_char?(pattern)
          end

          # Strict validator which ensures that only an appropriate response is given.
          #
          # @param resource [Resolv::DNS::Resource::IN] resource record type
          # @param response [String, Symbol, Array] response to include in callback
          #
          # @return [String] string representation of callback that can safely be eval'd
          def format_callback(resource, response)
            sym_regex = /^:?(NoError|FormErr|ServFail|NXDomain|NotImp|Refused|NotAuth)$/i

            src = if resource == Resolv::DNS::Resource::IN::A
              if response.is_a?(String) && BeEF::Filters.is_valid_ip?(:ipv4, response)
                sprintf "t.respond!('%s')", response
              elsif (response.is_a?(Symbol) && response.to_s =~ sym_regex) || response =~ sym_regex
                sprintf "t.fail!(:%s)", response.to_sym
              elsif response.is_a?(Array)
                str1 = "t.respond!('%s');"
                str2 = ''

                response.each do |r|
                  raise InvalidDnsResponseError, 'A' unless BeEF::Filters.is_valid_ip?(:ipv4, r)
                  str2 << sprintf(str1, r)
                end

                str2
              else
                raise InvalidDnsResponseError, 'A'
              end
            elsif resource == Resolv::DNS::Resource::IN::AAAA
              if response.is_a?(String) && BeEF::Filters.is_valid_ip?(:ipv6, response)
                sprintf "t.respond!('%s')", response
              elsif (response.is_a?(Symbol) && response.to_s =~ sym_regex) || response =~ sym_regex
                sprintf "t.fail!(:%s)", response.to_sym
              elsif response.is_a?(Array)
                str1 = "t.respond!('%s');"
                str2 = ''

                response.each do |r|
                  raise InvalidDnsResponseError, 'AAAA' unless BeEF::Filters.is_valid_ip?(:ipv6, r)
                  str2 << sprintf(str1, r)
                end

                str2
              else
                raise InvalidDnsResponseError, 'AAAA'
              end
            elsif resource == Resolv::DNS::Resource::IN::CNAME
              if response.is_a?(String) && BeEF::Filters.is_valid_domain?(response)
                sprintf "t.respond!(Resolv::DNS::Name.create('%s'))", response
              elsif (response.is_a?(Symbol) && response.to_s =~ sym_regex) || response =~ sym_regex
                sprintf "t.fail!(:%s)", response.to_sym
              else
                raise InvalidDnsResponseError, 'CNAME'
              end
            elsif resource == Resolv::DNS::Resource::IN::MX
              if response[0].is_a?(Integer) &&
                  BeEF::Filters.is_valid_domain?(response[1])

                data = { :preference => response[0], :exchange => response[1] }
                sprintf "t.respond!(%<preference>d, Resolv::DNS::Name.create('%<exchange>s'))", data
              elsif (response.is_a?(Symbol) && response.to_s =~ sym_regex) || response =~ sym_regex
                sprintf "t.fail!(:%s)", response.to_sym
              else
                raise InvalidDnsResponseError, 'MX'
              end
            elsif resource == Resolv::DNS::Resource::IN::NS
              if response.is_a?(String) && BeEF::Filters.is_valid_domain?(response)
                sprintf "t.respond!(Resolv::DNS::Name.create('%s'))", response
              elsif (response.is_a?(Symbol) && response.to_s =~ sym_regex) || response =~ sym_regex
                sprintf "t.fail!(:%s)", response.to_sym
              elsif response.is_a?(Array)
                str1 = "t.respond!(Resolv::DNS::Name.create('%s'))"
                str2 = ''

                response.each do |r|
                  raise InvalidDnsResponseError, 'NS' unless BeEF::Filters.is_valid_domain?(r)
                  str2 << sprintf(str1, r)
                end

                str2
              else
                raise InvalidDnsResponseError, 'NS'
              end
            elsif resource == Resolv::DNS::Resource::IN::PTR
              if response.is_a?(String) && BeEF::Filters.is_valid_domain?(response)
                sprintf "t.respond!(Resolv::DNS::Name.create('%s'))", response
              elsif (response.is_a?(Symbol) && response.to_s =~ sym_regex) || response =~ sym_regex
                sprintf "t.fail!(:%s)", response.to_sym
              else
                raise InvalidDnsResponseError, 'PTR'
              end
            elsif resource == Resolv::DNS::Resource::IN::SOA
              if response.is_a?(Array)
                unless BeEF::Filters.is_valid_domain?(response[0]) &&
                    BeEF::Filters.is_valid_domain?(response[1]) &&
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
            elsif resource == Resolv::DNS::Resource::IN::WKS
              if response.is_a?(Array)
                unless BeEF::Filters.is_valid_ip?(resource[0]) &&
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

            src
          end

          # Raised when an invalid pattern is given.
          class InvalidDnsPatternError < StandardError

            DEFAULT_MESSAGE = 'Failed to add DNS rule with invalid pattern'

            def initialize(message = nil)
              super(message || DEFAULT_MESSAGE)
            end

          end

          # Raised when a response is not valid for the given DNS resource record.
          class InvalidDnsResponseError < StandardError

            def initialize(message = nil)
              str = "Failed to add DNS rule with invalid response for %s resource record", message
              message = sprintf str, message unless message.nil?
              super(message)
            end

          end

          # Raised when an unknown DNS resource record is given.
          class UnknownDnsResourceError < StandardError

            DEFAULT_MESSAGE = 'Failed to add DNS rule with unknown resource record'

            def initialize(message = nil)
              super(message || DEFAULT_MESSAGE)
            end

          end

        end

      end
    end
  end
end
