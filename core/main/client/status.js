//
// Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - https://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/**
 * Status code helpers for module command results.
 * Modules use these when sending results back to the BeEF server.
 * @namespace beef.status
 */

beef.status = {
  /**
   * Success status code
   * @memberof beef.status
   * @method success
   * @return {number} 1
   */
  success: function(){
    return 1;
  },
  /**
   * Unknown status code
   * @memberof beef.status
   * @method unknown
   * @return {number} 0
   */
  unknown: function(){
    return 0;
  },
  /**
   * Error status code
   * @memberof beef.status
   * @method error
   * @return {number} -1
   */
  error: function(){
    return -1;
  }
};
beef.regCmp("beef.status");
