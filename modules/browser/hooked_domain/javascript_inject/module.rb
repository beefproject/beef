class Javascript_inject < BeEF::Core::Command
  
  def self.options
    return [
        { 'ui_label'=>'Javascript Inject', 'name'=>'javascript_inject', 'description' => 'Inject javascript into the source of a page', 'value'=>'<img src= >', 'width'=>'200px' }
    ]
  end

  def post_execute
    save({'result' => @datastore['result']})
  end
  
end
