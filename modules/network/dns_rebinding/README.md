# Manual to DNS Rebinding (aka Anti DNS Pinning aka multiple A record) attack #

## How does attack work in general? ##

Attacker must have some domain and DNS server responds to DNS query for this domain.

When client's browser connects to the attacker's domain it gets two IP addresses:

* First IP address in the DNS response is address of Web page with malicious JavaScript.

* Second IP address is from victim's LAN, it is a target address.

The client's browser connects to the first IP address in the DNS response and retrieves the HTML file containing the attacker's
JavaScript.

When the attacker's JavaScript initiates a request back to the attacker's domain via an
XMLHttpRequest, the browser will again try to connect to the attacker's Web server. However,
since the client's IP is now blocked, the browser will receive a TCP reset packet from the
attacker's Web server.

The browser will automatically attempt to use the second IP address listed in the DNS response,
which is the IP address of the client’s router. The attacker's JavaScript can now send requests to
the router as well as view the responses.

## How to launch attack in BeEF? ##

1. First of all, you should register domain, for example *dnsrebinding.org* and register NS server with IP address where BeEF DNS server launched. For tests you can use https://freedns.afraid.org, free third-level domain registrar.
2. Configure DNS Rebinding extension and module. In extension there are four main configs:

* *address_http_internal* - IP Address of small HTTP Server, that hooks victim. That address will be in DNS response for victim.

* *address_http_external* - If you behind NAT 

* *address_proxy_internal* - Victim will send on that address responses from target LAN IP. May be the same as address_http.

* *address_proxy_external* - If you behind NAT

* *port_ proxy* - 81 by default

In module main config is *domain*. Module adds  DNS rule to BeEF DNS database with the help of this config. 

3. Hook victim by help of link contains new registered domain, for example *http://dnsrebinding.org*
4. In BeEF UI open module "DNS Rebinding" and fill *target* field. (That is target IP from victim's LAN, for example 192.168.0.1) Then launch module for hooked browser. Module adds DNS rule with double A record in BeEF DNS database and sends JS.
4. Victim's browser will send query to small HTTP Server of DNS Rebinding extension. Then extension block IP with the help of iptables. Then victim's browser will initiate second XMLHttpRequest to page. And that will be query to target IP. Then sends response from target IP to DNS Rebinding Proxy server. 
5. Open in your browser page http://address_proxy:port_proxy/**path**, where **path** is path you want get from target IP.
    For example, if **path** = **login.html** and target IP is 192.168.0.1 you get HTML page from victim's router, the same as http://192.168.0.1/login.php
6. That is all.

Notice, attack is VERY DEMANDING, there are many things that can break it. For example:
1. If victim's browser already have established connection with target IP in other tab, when browser gets DNS response from BeEF DNS server it will use second (local) IP address instead of public address.
2. If victim's browser have unclear cache with target IP address, browser will use local IP.
3. (!) If victim even has closed, TIME WAIT connection with target IP address - the same, browser will use local IP
4. If victim broke attack (for example close tab with hook page), browser anyway save in cache ip address (local) of web page, and you should wait some time while cache will be clear again. In different browsers that time different.

## References ##
1. http://en.wikipedia.org/wiki/DNS_rebinding
1. https://code.google.com/p/rebind/downloads/list    - DNS Rebinding tool implemented on C. Very good explanation of attack in archive: /docs/whitepaper.pdf