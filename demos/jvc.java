import java.applet.Applet;

public class jvc extends Applet
{
	private String m_ver;
	private String m_ven;

	public void init()
	{
		m_ver = System.getProperty("java.version");
		m_ven = System.getProperty("java.vendor");
	}

	public boolean isRunning()
	{
		return true;
	}

	public String getVersion()
	{
		return m_ver;
	}

	public String getVendor()
	{
		return m_ven;
	}
} 
