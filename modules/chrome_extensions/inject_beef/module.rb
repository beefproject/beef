class Inject_beef < BeEF::Core::Command

  def post_execute
    content = {}
    content['Return'] = @datastore['return']
    save content
  end
  
end
