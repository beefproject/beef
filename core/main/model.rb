#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

module BeEF
  module Core
    class Model < ActiveRecord::Base
      # Tell ActiveRecord that this is not a model
      self.abstract_class = true
    end
  end
end
