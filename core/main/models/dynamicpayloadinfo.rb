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
module Core
module Models

  class DynamicPayloadInfo
  
    include DataMapper::Resource
  
    storage_names[:default] = 'core_dynamicpayloadinfo'
  
    property :id, Serial
    property :name, String, :length => 30
    property :value, String, :length => 255
    property :required, Boolean, :default => false
    property :description, Text, :lazy => false
  
    belongs_to :dynamic_payloads
  
  end

end
end
end