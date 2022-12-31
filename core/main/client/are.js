//
// Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/** 
 * A series of functions that handle statuses, returns a number based on the function called.
 * @namespace beef.are
 */

beef.are = {
  /**
   * A function for handling a success status
   * @memberof beef.are
   * @method status_success 
   * @return {number} 1
   */
  status_success: function(){
    return 1;
  },
  /**
   * A function for handling an unknown status
   * @memberof beef.are
   * @method status_unknown 
   * @return {number} 0
   */  
  status_unknown: function(){
    return 0;
  },
  /**
   * A function for handling an error status
   * @memberof beef.are
   * @method status_error 
   * @return {number} -1
   */  
  status_error: function(){
    return -1;
  }
};
beef.regCmp("beef.are");
