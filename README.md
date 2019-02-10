===============================================================================

    Copyright (c) 2006-2019 Wade Alcorn - wade@bindshell.net
    Browser Exploitation Framework (BeEF) - http://beefproject.com
    See the file 'doc/COPYING' for copying permission

===============================================================================

What is BeEF?
-------------

__BeEF__ is short for __The Browser Exploitation Framework__. It is a penetration testing tool that focuses on the web browser.

Amid growing concerns about web-borne attacks against clients, including mobile clients, BeEF allows the professional penetration tester to assess the actual security posture of a target environment by using client-side attack vectors. Unlike other security frameworks, BeEF looks past the hardened network perimeter and client system, and examines exploitability within the context of the one open door: the web browser. BeEF will hook one or more web browsers and use them as beachheads for launching directed command modules and further attacks against the system from within the browser context.


Get Involved
------------

You can get in touch with the BeEF team. Just check out the following:


__Please, send us pull requests!__

__Web:__ https://beefproject.com/

__Bugs:__ https://github.com/beefproject/beef/issues

__Security Bugs:__ security@beefproject.com

__IRC:__ ircs://irc.freenode.net/beefproject

__Twitter:__ @beefproject


Requirements
------------

* Operating System: Mac OSX 10.5.0 or higher / modern Linux. Note: Windows is not supported.
* [Ruby](http://ruby-lang.org): 2.4 or newer
* [SQLite](http://sqlite.org): 3.x
* [Node.js](https://nodejs.org): 6 or newer
* The gems listed in the Gemfile: https://github.com/beefproject/beef/blob/master/Gemfile
* Selenium is required on OSX: brew install selenium-server-standalone (See https://github.com/shvets/selenium)


Quick Start
-----------

__The following is for the impatient.__

The `install` script installs the required operating system packages and all the prerequisite Ruby gems:

```
$ ./install
```

For full installation details, please refer to [INSTALL.txt](https://github.com/beefproject/beef/blob/master/INSTALL.txt).

We also have an [Installation](https://github.com/beefproject/beef/wiki/Installation) page on the wiki.

Upon successful installation, be sure to read the [Configuration](https://github.com/beefproject/beef/wiki/Configuration) page on the wiki for important details on configuring and securing BeEF.


Usage
-----

To get started, simply execute beef and follow the instructions:

```
$ ./beef
```
