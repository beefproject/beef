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
module API

  module Command
  end

  module Module
    
    API_PATHS = {
        'pre_soft_load' => :pre_soft_load,
        'post_soft_load' => :post_soft_load,
        'pre_hard_load' => :pre_hard_load,
        'post_hard_load' => :post_hard_load
    }
    
    def pre_soft_load(mod); end

    def post_soft_load(mod); end

    def pre_hard_load(mod); end

    def post_hard_load(mod); end

  end
  
end
end
