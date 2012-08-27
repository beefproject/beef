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
module Extension
module SocialEngineering
  extend BeEF::API::Extension

  @short_name = 'social_engineering'
  @full_name = 'Social Engineering'
  @description = 'Phishing attacks for your pleasure: web page cloner (POST interceptor and BeEF goodness), highly configurable mass mailer, etc.'
end
end
end

require 'extensions/social_engineering/web_cloner/web_cloner'
require 'extensions/social_engineering/web_cloner/interceptor'


