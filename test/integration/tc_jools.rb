#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'
require '../common/beef_test'
require '../common/test_constants'

class TC_Jools < Test::Unit::TestCase

    #test jools can be acces and a new object can be instantiated
    def test_jools_exists
        victim = BeefTest.new_victim
        script = "return require('jools');"
        jools = victim.execute_script(script)
        assert_not_nil jools
        script = "var Jools = require('jools');
        return new Jools([]);"
        jools_obj = victim.execute_script(script)
        assert_not_nil jools_obj
        victim.reset_session!
    end

    #test simple jools rule example
    def test_jools_simple
        victim = BeefTest.new_victim
        script = " var Jools = require('jools');
            var rules = [{
            'name':'Lights on after 8pm',
            'condition': function(hour){
                return hour >= 8;
            },
            'consequence': function(){
                this.state = 'on';
            }
            }];
            var fact = {
                'hour':8,
                'minute':21
            };
            var j = new Jools(rules);
            var result = j.execute(fact);
            return result.state;"
       result = victim.execute_script(script)
       assert_equal result,'on'
    end

    #test jools chaining example
    def test_jools_chaning
        victim = BeefTest.new_victim
        script = " var Jools = require('jools');
            var rules = [
            {'name':'frog is green',
            'condition': function(animal){
                return animal == 'frog';
            },
            'consequence': function(){
                this.color = 'green';
            }},
            {'name':'canary is yellow',
            'condition': function(animal){
                return animal == 'canary';
            },
            'consequence': function(){
                this.color = 'yellow';
            }},
            {'name':'croaks and eats flies',
            'condition' : function(eats){
                return eats && eats.indexOf('croaks') >= 0 && eats.indexOf('flies') >=0;
            },
            'consequence': function(){
                this.animal = 'frog';
            }},
            {'name':'chirps and sings',
            'condition' : function(does){
                return does && does.indexOf('chirps') >= 0 && does.indexOf('sings') >=0;
            },
            'consequence': function(){
                this.animal = 'canary';
            }}
            ];
            var fact_1 = {
                'name':'fritz',
                'eats': ['croaks','flies']
            };
            var fact_2 = {
                'name':'fritz',
                'eats': ['croaks','rocks']
            };
            var fact_3 = {
                'name':'tweety',
                'does': ['sings','chirps']
            };
            var fact_4 = {
                'name':'tweety',
                'does': ['chrips','howls']
            };

            var j = new Jools(rules);
            var results = [];
             results.push(j.execute(fact_1));
             results.push(j.execute(fact_2));
             results.push(j.execute(fact_3));
             results.push(j.execute(fact_4));
            return results;"
       results = victim.execute_script(script)
       assert_not_nil results
       assert_equal results[0]['color'],'green'
       assert_not_equal results[1]['color'], 'green'
       assert_equal results[2]['color'],'yellow'
       assert_not_equal results[3]['color'], 'yellow'
    end
end
