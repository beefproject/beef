module BeEF
module UI

#
#
#
class Panel < BeEF::HttpController
  
  def initialize
    super({
      'paths' => {
        'index' => '/'
      }
    })
  end
  
  #
  def index
    @body = 'a'
  end
  
end

end
end