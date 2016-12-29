//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

// beef.net.connection - wraps Mozilla's Network Information API
// https://developer.mozilla.org/en-US/docs/Web/API/NetworkInformation
// https://developer.mozilla.org/en-US/docs/Web/API/Navigator/connection
beef.net.connection = {

  /* Returns the connection type
   * @example: beef.net.connection.type()
   * @note: https://developer.mozilla.org/en-US/docs/Web/API/NetworkInformation/type
   * @return: {String} connection type or 'unknown'.
   **/
  type: function () {
    try {
      var connection = navigator.connection || navigator.mozConnection || navigator.webkitConnection;
      var type = connection.type;
      if (/^[a-z]+$/.test(type)) return type; else return 'unknown';
    } catch(e) {
      beef.debug("Error retrieving connection type: " + e.message);
      return 'unknown';
    }
  },

  /* Returns the maximum downlink speed of the connection
   * @example: beef.net.connection.downlinkMax()
   * @note: https://developer.mozilla.org/en-US/docs/Web/API/NetworkInformation/downlinkMax
   * @return: {String} downlink max or 'unknown'.
   **/
  downlinkMax: function () {
    try {
      var connection = navigator.connection || navigator.mozConnection || navigator.webkitConnection;
      var max = connection.downlinkMax;
      if (max) return max; else return 'unknown';
    } catch(e) {
      beef.debug("Error retrieving connection downlink max: " + e.message);
      return 'unknown';
    }
  }

};

beef.regCmp('beef.net.connection');

