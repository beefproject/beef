//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.are = {
  status_success: function(){
    return 1;
  },
  status_unknown: function(){
    return 0;
  },
  status_error: function(){
    return -1;
  }
};
beef.regCmp("beef.are");
