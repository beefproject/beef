# Submit Issue

Verify first that your issue/request has not been posted previously:

* https://github.com/beefproject/beef/issues
* https://github.com/beefproject/beef/wiki/FAQ

Ensure you're using the [latest version of BeEF](https://github.com/beefproject/beef/releases/tag/beef-0.5.0.0).

Please do your best to provide as much information as possible. It will help substantially if you can enable and provide debugging logs with your issue. Instructions for enabling debugging logs are below:

1. In the `config.yaml` file of your BeEF root folder set debug and client_debug (lines 11 & 13 respectively) to `true`
   * If using a standard installation of `beef-xss` the root folder will typicaly be `/usr/share/beef-xss`
2. Reproduce your error
3. Retrieve your client-side logs from your browser's developer console (Ctrl + Shift + I)
4. Retrieve your server-side logs from `~/.beef/beef.log`
5. **If using `beef-xss`:** Retrieve your service logs using `journalctl -u beef-xss`

Thank you, this will greatly aid us in identifying the root cause of your issue :)

**If we request additional information and we don't hear back from you within a week, we will be closing the ticket off.**
Feel free to open it back up if you continue to have issues. 

## Summary

**Q:** Please provide a brief summary of the issue that you experienced.
**A:**

## Environment

*Please identify the environment in which your issue occurred.*

1. **BeEF Version:**

2. **Ruby Version:**

3. **Browser Details (e.g. Chrome v81.0):**

4. **Operating System (e.g. OSX Catalina):**


## Configuration

**Q:** Have you made any changes to your BeEF configuration? 
**A:**

**Q:** Have you enabled or disabled any BeEF extensions?
**A:**

## Expected vs. Actual Behaviour

**Expected Behaviour:** 
<br />
**Actual Behaviour:**
<br />

## Steps to Reproduce

*Please provide steps to reproduce this issue.*

1.


## Additional Information

Please provide any additional information which may be useful in resolving this issue, such as debugging output and relevant screen shots. Debug output can be retrieved by following the instructions towards the top of the issue template.
