//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.are = {
  init:function(){
   var Jools = require('jools');
   this.ruleEngine = new Jools();
  },
  rules:[],
  commands:[],
  results:[]
};
beef.regCmp("beef.are");