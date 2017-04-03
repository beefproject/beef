class Jsonp_service_worker < BeEF::Core::Command

  def post_execute
    save({'result' => @datastore['result']})
  end

  def self.options
    return [
      {'name' => 'JSONPPath', 'ui_label' => 'Path of the current domain compromized JSONP endpoint (ex: /jsonp?callback=)', 'value' => '/jsonp?callback='},
      {'name' => 'tempBody', 'ui_label' => 'Temporary HTML body to show to the users (ASCII HEX encoding needed)', 'value' => '%3Ch3%3EUnplanned%20site%20maintenance,%20please%20wait%20a%20few%20seconds,%20we%20are%20almost%20done.%3C%2Fh3%3E'}
    ]
  end

end
