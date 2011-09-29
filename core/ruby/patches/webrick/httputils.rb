#
# httputils.rb -- HTTPUtils Module
#
# Author: IPR -- Internet Programming with Ruby -- writers
# Copyright (c) 2000, 2001 TAKAHASHI Masayoshi, GOTOU Yuuzou
# Copyright (c) 2002 Internet Programming with Ruby writers. All rights
# reserved.
#
# $IPR: httputils.rb,v 1.34 2003/06/05 21:34:08 gotoyuzo Exp $


module WEBrick

  module HTTPUtils

	# Add support for additional mime types
    # @param [String] filename Filename
    # @param [Hash] mime_tab Mime Type Hash
    def mime_type(filename, mime_tab)
      suffix1 = (/\.(\w+)$/ =~ filename && $1.downcase)
      suffix2 = (/\.(\w+)\.[\w\-]+$/ =~ filename && $1.downcase)
			
			# @todo Add support for additional mime types
			supported_mime_types = {
					'wav' => 'audio/x-wav'					
					}
			
			mime_tab.merge!(supported_mime_types)
			
			mime_tab[suffix1] || mime_tab[suffix2] || "application/octet-stream"
    end
    module_function :mime_type
		
  end
end
