module BeEF
module UI

#
#
#
class Panel < BeEF::HttpController
  
  def initialize
    super({
      'paths' => {
        '/' => method(:index)
      }
    })
  end
  
  #
  def index
    # should be rendered with Erubis::FastEruby
    @body = 'a'
  end
  
end

end
end