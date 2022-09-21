## First Steps

1. Confirm that your issue has not been posted previously by searching here: https://github.com/beefproject/beef/issues
2. Confirm that the wiki does not contain the answers you seek: https://github.com/beefproject/beef/wiki
3. Check the FAQ: https://github.com/beefproject/beef/wiki/FAQ
4. BeEF Version:
5. Ruby Version:
6. Browser Details (e.g. Chrome v81.0):
7. Operating System (e.g. OSX Catalina):

## Configuration

1. Have you made any changes to your BeEF configuration? Yes/No
2. Have you enabled or disabled any BeEF extensions? Yes/No

## Steps to Reproduce

1. (eg. I ran install script, which ran fine)
2. (eg. when launching console with './beef' I get an error as follows: <error here>)
3. (eg. beef does not launch)

## How to enable and capture detailed logging

1. Edit `config.yaml` in the root directory
   * If using Kali **beef-xss** the root dir will be  `/usr/share/beef-xss`
2. Update `client_debug` to `true`
3. Retrieve browser logs from your browser's developer console (Ctrl + Shift + I or F12 depending on browser)
4. Retrieve your server-side logs from `~/.beef/beef.log`
   * If using **beef-xss** logs found with `journalctl -u beef-xss`

**If we request additional information and we don't hear back from you within a week, we will be closing the ticket off.**
