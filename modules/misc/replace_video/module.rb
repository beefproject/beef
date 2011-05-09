class Replace_video < BeEF::Core::Command

  #
  # Defines and set up the command module.
  #
  def initialize
    super({
      'Name' => 'Replace Video',
      'Description' => 'Replaces an object selected with jQuery (all embed tags by default) with an embed tag containing the youtube video of your choice (rickroll by default).',
      'Category' => 'Misc',
      'Author' => 'Yori Kvitchko',
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