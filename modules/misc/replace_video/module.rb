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
class Replace_video < BeEF::Core::Command

  #
  # Defines and set up the command module.
  #
  def initialize
    super({
      'Name' => 'Replace Video',
      'Description' => 'Replaces an object selected with jQuery (all embed tags by default) with an embed tag containing the youtube video of your choice (rickroll by default).',
      'Category' => 'Misc',
      'Author' => ['Yori Kvitchko','antisnatchor'],
      'Data' =>
        [
			    {'name' => 'youtube_id', 'ui_label' => 'YouTube Video ID', 'value' => 'XZ5TajZYW6Y', 'width'=>'150px'},
			    {'name' => 'jquery_selector', 'ui_label' => 'jQuery Selector', 'value' => 'embed', 'width'=>'150px'}
        ],
      'File' => __FILE__
    })

    set_target({
      'verified_status' =>  VERIFIED_USER_NOTIFY, 
      'browser_name' =>     ALL
    })

    use 'beef.dom'
    use_template!
  end

  def callback
    content = {}
    content['Result'] = @datastore['result']
    save content

  end

end