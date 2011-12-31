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
  #
  # Store the XssRays scans started and finished, with relative ID
  #
  class Xssraysscan

    include DataMapper::Resource

    storage_names[:default] = 'extension_xssrays_scans'

    property :id, Serial

    property :hooked_browser_id, Text, :lazy => false

    property :scan_start, DateTime, :lazy => true
    property :scan_finish, DateTime, :lazy => true

    property :domain, Text, :lazy => true
    property :cross_domain, Text, :lazy => true
    property :clean_timeout, Integer, :lazy => false

    property :is_started, Boolean, :lazy => false, :default => false
    property :is_finished, Boolean, :lazy => false, :default => false

    has n, :extension_xssrays_details, 'Xssraysdetail'

  end

end
end
end
