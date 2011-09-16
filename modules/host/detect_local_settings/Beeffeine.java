import java.applet.*;
import java.net.*;
import java.util.*;

public class Beeffeine extends Applet {

	public String MyIP()
	{
		String string = "unknown";
		String string4 = getDocumentBase().getHost();
		byte j = 80;
		String string2;
		String string3 = "internal_ip=";
		int k = 80;
		if (getDocumentBase().getPort() != -1) 
			k = getDocumentBase().getPort();

		try {
			string2 = new Socket(string4 , k).getLocalAddress().getHostAddress();
			if (!string2.equals("255.255.255.255")) 
				string3 += string2;

		}
		catch (SecurityException securityexception) {
			string3 += "FORBIDDEN";
		}
		catch (Exception exception) {
			string3 += "exception";
		}

		string3 += "&internal_hostname=";

		try {
			string3 += new Socket(string4 , k).getLocalAddress().getHostName();
		}
		catch (Exception exception) {
			string3 += "Cannot Lookup this IP";
		}

		return (string3);
	}
	
	public Beeffeine() {
		super();
		return;
	}
	
}
