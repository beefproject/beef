class Jsonp_service_worker < BeEF::Core::Command

  def post_execute
    save({'result' => @datastore['result']})
  end

  def self.options
    return [
      {'name' => 'JSONPPath', 'ui_label' => 'Path of the current domain compromized JSONP endpoint (ex: /jsonp?callback=)', 'value' => '/jsonp?callback='}
    ]
  end

end
