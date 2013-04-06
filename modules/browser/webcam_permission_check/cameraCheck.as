//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

// Source ActionScript for cameraCheck.swf
package {

    import flash.display.Sprite;
    import flash.external.ExternalInterface;
    import flash.media.Camera;
    import flash.system.Security;
    import flash.system.SecurityPanel;

    public class CamCheck extends Sprite {

        var _cam:Camera;

        public function CamCheck() {

            if (Camera.isSupported)     {
                this._cam = Camera.getCamera();

                if (!this._cam) {

	                //Either the camera is not available or some other error has occured
                    ExternalInterface.call("naPermissions");

                } else if (this._cam.muted) {

	                //The user has not allowed access to the camera
                    ExternalInterface.call("noPermissions");

                    // Uncomment this show the privacy/security settings window
                    //Security.showSettings(SecurityPanel.PRIVACY);
                } else {

                    //The user has allowed access to the camera
                    ExternalInterface.call("yesPermissions");
                }

            } else {

                //Camera Not Supported
                ExternalInterface.call("naPermissions");

            }

        }

    }

}