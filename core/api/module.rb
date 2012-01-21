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
module BeEF
  module API

    module Command
    end

    module Module

      # @note Defined API Paths
      API_PATHS = {
          'pre_soft_load' => :pre_soft_load,
          'post_soft_load' => :post_soft_load,
          'pre_hard_load' => :pre_hard_load,
          'post_hard_load' => :post_hard_load,
          'get_options' => :get_options,
          'get_payload_options' => :get_payload_options,
          'override_execute' => :override_execute
      }

      # Fired before a module soft load
      # @param [String] mod module key of module about to be soft loaded
      def pre_soft_load(mod); end

      # Fired after module soft load
      # @param [String] mod module key of module just after soft load
      def post_soft_load(mod); end

      # Fired before a module hard load
      # @param [String] mod module key of module about to be hard loaded
      def pre_hard_load(mod); end

      # Fired after module hard load
      # @param [String] mod module key of module just after hard load
      def post_hard_load(mod); end

      # Fired before standard module options are returned
      # @return [Hash] a hash of options
      # @note the option hash is merged with all other API hook's returned hash. Hooking this API method prevents the default options being returned.
      def get_options; end

      # Fired just before a module is executed
      # @param [String] mod module key
      # @param [String] hbsession hooked browser session id
      # @param [Hash] opts a Hash of options
      # @note Hooking this API method stops the default flow of the Module.execute() method.
      def override_execute(mod, hbsession, opts); end

      # Fired when retreiving dynamic payload
      # @return [Hash] a hash of options
      # @note the option hash is merged with all other API hook's returned hash. Hooking this API method prevents the default options being returned.
      def get_payload_options; end

    end

  end
end
