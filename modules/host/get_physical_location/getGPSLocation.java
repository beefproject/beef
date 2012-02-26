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
			//System.out.println("This is Windows Machine");
			result=getWindows();
		} else if (isMac()) {
			//System.out.println("This is Mac Machine");
			result=getMac();
		} else {
			//System.out.println("Your OS is not support!!");
		}
	}
	
	public static String getWindows(){
			String result = null;
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
			//System.out.println("I don't know where the target is");
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
	    try {  
			int j=0;
			String queryString = "https://maps.googleapis.com/maps/api/browserlocation/json?browser=firefox&sensor=true";
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
					
			//Get geocoordinates / Longitude and Latitude
			String geoCoordinates = null;		

			URL url = new URL(queryString);
			URLConnection urlc = url.openConnection();
			urlc.setRequestProperty("User-Agent", "Mozilla 5.0 (Windows; U; "+ "Windows NT 5.1; en-US; rv:1.8.0.11) ");
			BufferedReader reader = new BufferedReader(new InputStreamReader(urlc.getInputStream()));		
			for (String output; (output = reader.readLine()) != null;) {
				//System.out.println(output);
				if(output.indexOf("18000.0")>0){
					result+="\nLocation is not accurate\n";
					//System.out.println("Location is not accurate\n");
				}
				else{	
					if(output.indexOf("lat")>0){
						output = output.replace("\"lat\" : ","");
						output = output.replaceAll("^\\s+", "");
						geoCoordinates = output;
						result+="\nLatitude: ";
						result+=output;
						//System.out.println("Latitude: "+output);
					}
					if(output.indexOf("lng")>0){
						output = output.replace("\"lng\" : ","");
						output = output.replaceAll("^\\s+", "");
						geoCoordinates += output;
						result+="\nLongitude: ";
						result+=output;
						//System.out.println("Longitude: "+output);
					}
				}
				
			}
			
		
			//Reverse geocoordinates to street address
			String reverseGeo = "https://maps.googleapis.com/maps/geo?q="+geoCoordinates+"&output=json&sensor=true_or_false";
			
			//System.out.println(reverseGeo);

				URL url1 = new URL(reverseGeo);
				URLConnection urlc1 = url1.openConnection();
				urlc1.setRequestProperty("User-Agent", "Mozilla 5.0 (Windows; U; "+ "Windows NT 5.1; en-US; rv:1.8.0.11) ");
			BufferedReader reader1 = new BufferedReader(new InputStreamReader(urlc1.getInputStream()));		
			for (String output1; (output1 = reader1.readLine()) != null;) {
				if(output1.indexOf("address")>0){
					output1 = output1.replace("\"address\": ",""); 
					output1 = output1.replace("\",",""); 
					output1 = output1.replace("\"",""); 
					output1 = output1.replaceAll("^\\s+", "");
					result+="\nAddress is ";
					result+=output1;
					//System.out.println("Address is "+output1);
				}
			}		
			String mapAddress = "http://maps.google.com/maps?q="+geoCoordinates+"+%28You+are+located+here%29&iwloc=A&hl=en";
			result+="\n"+mapAddress;
			//System.out.println("\n"+mapAddress);
		} catch (Exception e) { 
			System.out.println(e.getMessage());
		}
		return result;		
	}
	
	public static String getMac(){
		String result = null;	
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
				//System.out.println("I don't know where the target is");
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
