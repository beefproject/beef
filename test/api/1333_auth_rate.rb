#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'test/unit'

require 'pry-byebug'
require 'rest-client'
require 'json'
require 'optparse'
require 'pp'

require '../common/test_constants'
require './lib/beef_rest_client'

class TC_1333_auth_rate < Test::Unit::TestCase

  def test_auth_rate
    # tests rate of auth calls
    # this takes some time - with no output
    # beef must be running

    passwds = (1..9).map { |i| "broken_pass"}
    passwds.push BEEF_PASSWD
    apis = passwds.map { |pswd| BeefRestClient.new('http', ATTACK_DOMAIN, '3000', BEEF_USER, pswd) }
    l = apis.length

    # t0 = Time.now()


    (0..2).each do |again|      # multiple sets of auth attempts
      # first pass -- apis in order, valid passwd on 9th attempt
      # subsequent passes apis shuffled

      # puts "speed requesets"    # all should return 401
      (0..50).each do |i|
        # t = Time.now()
        # puts "#{i} : #{t - t0} : #{apis[i%l].auth()[:payload]}"

        test_api = apis[i%l]
        assert_match("401", test_api.auth()[:payload]) # all (unless the valid is first 1 in 10 chance)

        # t0 = t
      end

      # again with more time between calls -- there should be success (1st iteration)
      # puts "delayed requests"
      (0..(l*2)).each do |i|
        # t = Time.now()
        # puts "#{i} : #{t - t0} : #{apis[i%l].auth()[:payload]}"

        test_api = apis[i%l]
        if (test_api.is_pass?(BEEF_PASSWD))
          assert(test_api.auth()[:payload]["success"]) # valid pass should succeed
        else
          assert_match("401", test_api.auth()[:payload])
        end

        sleep(0.5)
        # t0 = t
      end

      apis.shuffle! # new order for next iteration
      apis.reverse if (apis[0].is_pass?(BEEF_PASSWD)) # prevent the first from having valid passwd

    end                         # multiple sets of auth attempts

  end                           # test_auth_rate


end
