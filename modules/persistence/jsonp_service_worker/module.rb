class Jsonp_service_worker < BeEF::Core::Command

  def post_execute
    save({'result' => @datastore['result']})
  end

  def self.options
    return [
      {'name' => 'JSONPPath', 'ui_label' => 'Path of the current domain compromized JSONP endpoint (ex: /jsonp?callback=)', 'value' => '/jsonp?callback='},
      {'name' => 'tempBody', 'ui_label' => 'Temporary HTML body to show to the users', 'value' => '<h3>Unplanned site maintenance, please wait a few seconds, we are almost done.</h3>'}
    ]
  end

end
