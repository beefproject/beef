#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# less noisy verson of BeeRestAPI found in tools.
class BeefRestClient
  def initialize proto, host, port, user, pass
    @user = user
    @pass = pass
    @url = "#{proto}://#{host}:#{port}/api/"
    @token = nil
  end

  def auth
    begin
      response = RestClient.post "#{@url}admin/login",
                                 { 'username' => "#{@user}",
                                   'password' => "#{@pass}" }.to_json,
                                 :content_type => :json,
                                 :accept => :json
      result = JSON.parse(response.body)
      @token = result['token']
      {:success => result['success'], :payload => result}
    rescue => e
      {:success => false, :payload => e.message }
       end
  end

  def version
    return {:success => false, :payload => 'no token'} if @token.nil?
    begin
      response = RestClient.get "#{@url}server/version", {:params => {:token => @token}}
      result = JSON.parse(response.body)

      {:success => result['success'], :payload => result}
    rescue => e
      print_error "Could not retrieve BeEF version: #{e.message}"
      {:success => false, :payload => e.message}
       end
  end
end
