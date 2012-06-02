
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