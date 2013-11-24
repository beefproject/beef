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
  send:function(module){
    // there will probably be some other stuff here before things are finished
    this.commands.push(module);
  },
  execute:function(inputs){
    this.rulesEngine.execute(input);
  },
  cache_modules:function(modules){},
  rules:[
    {
      'name':"exec_no_input",
      'condition':function(command,browser){
          //need to figure out how to handle the inputs
          return (!command['inputs'] || command['inputs'].length == 0)
       },
      'consequence':function(command,browser){}
    },
    {
      'name':"module_has_sibling",
      'condition':function(command,commands){
        return false;
      },
      'consequence':function(command,commands){}
    },
    {
      'name':"module_depends_on_module",
      'condition':function(command,commands){
        return false;
      },
      'consequence':function(command,commands){}
    }
  ],
  commands:[],
  results:[]
};
beef.regCmp("beef.are");
