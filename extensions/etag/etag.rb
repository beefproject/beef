#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module ETag

    require 'sinatra/base'
    require 'singleton'
    
    class ETagMessages
        include Singleton
        attr_accessor :messages
       
        def initialize()
            @messages={}
        end
    end
    
    class ETagWebServer < Sinatra::Base
        def create_ET_header
            inode = File.stat(__FILE__).ino
            size  = 3
            mtime = (Time.now.to_f * 1000000).to_i
            return "#{inode.to_s(16)}L-#{size.to_s(16)}L-#{mtime.to_s(16)}L"
        end

        get '/:id/start' do
            data = ETagMessages.instance.messages[params[:id].to_i]
	  
            $etag_server_state = {} unless defined?($etag_server_state)
            $etag_server_state[params[:id]]               = {}
            $etag_server_state[params[:id]][:cur_bit]     = -1
            $etag_server_state[params[:id]][:last_header] = create_ET_header 
	        $etag_server_state[params[:id]][:message]     = data
	    
	        headers "ETag" => $etag_server_state[params[:id]][:last_header]
            body "Message start"
        end

	    get '/:id' do
            return "Not started yet" if !defined?($etag_server_state) || $etag_server_state[params[:id]].nil?
            if  $etag_server_state[params[:id]][:cur_bit] < $etag_server_state[params[:id]][:message].length - 1
                $etag_server_state[params[:id]][:cur_bit] += 1
            else
                $etag_server_state.delete(params[:id])
                status 404
                return "Bing"
            end
            
            if $etag_server_state[params[:id]][:message][$etag_server_state[params[:id]][:cur_bit]] == '1'
                $etag_server_state[params[:id]][:last_header] = create_ET_header
            end

            headers "ETag" => $etag_server_state[params[:id]][:last_header]
            body "Bit"
        end
   end
end
end
end
