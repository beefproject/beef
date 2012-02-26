#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
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


# @note The following file contains patches for DataMapper Data Objects Adapter (dm-do-adapter)
#   This patch fixes the following error:
#   DataObjects::URI.new with arguments is deprecated, use a Hash of URI components (/home/username/.rvm/gems/ruby-1.9.2-p290/gems/dm-do-adapter-1.1.0/lib/dm-do-adapter/adapter.rb:231:in `new')
#   The error is patched in dm-do-adapter 1.1.1 however it has yet to be released.
#   Patch: https://github.com/datamapper/dm-do-adapter/commit/7f0b53d1ada8735910e04ff37d60c6ff037ce288

=begin
Deleted:
<             DataObjects::URI.new(
<               @options[:adapter],
<               @options[:user] || @options[:username],
<               @options[:password],
<               @options[:host],
<               port,
<               @options[:path] || @options[:database],
<               query,
<               @options[:fragment]
<             ).freeze

Added:
>             DataObjects::URI.new({
>               :scheme     => @options[:adapter],
>               :user       => @options[:user] || @options[:username],
>               :password   => @options[:password],
>               :host       => @options[:host],
>               :port       => port,
>               :path       => @options[:path] || @options[:database],
>               :query      => query,
>               :fragment   => @options[:fragment]
>             }).freeze
=end

require 'dm-do-adapter'

module DataMapper
  module Adapters
    class DataObjectsAdapter < AbstractAdapter

      def normalized_uri
        @normalized_uri ||=
            begin
              keys = [
                  :adapter, :user, :password, :host, :port, :path, :fragment,
                  :scheme, :query, :username, :database ]
              query = DataMapper::Ext::Hash.except(@options, keys)
              query = nil if query.empty?

              # Better error message in case port is no Numeric value
              port = @options[:port].nil? ? nil : @options[:port].to_int

              DataObjects::URI.new({
                                       :scheme     => @options[:adapter],
                                       :user       => @options[:user] || @options[:username],
                                       :password   => @options[:password],
                                       :host       => @options[:host],
                                       :port       => port,
                                       :path       => @options[:path] || @options[:database],
                                       :query      => query,
                                       :fragment   => @options[:fragment]
                                   }).freeze
            end
      end

    end
  end
end

