#
# Copyright (c) 2006-2020 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

#
# @note log to file
#
module BeEF
  class << self
    attr_writer :logger

    def logger
        @logger ||= Logger.new("#{$home_dir}/beef.log").tap do |log|
        log.progname = self.name
        log.level = Logger::WARN
      end
    end
  end
end
