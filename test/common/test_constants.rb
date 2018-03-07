#
# Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
BEEF_TEST_DIR = "/tmp/beef-test/"

# General constants
ATTACK_DOMAIN = "127.0.0.1"
VICTIM_DOMAIN = "localhost"
ATTACK_URL = "http://" + ATTACK_DOMAIN + ":3000/ui/panel"
VICTIM_URL = "http://" + VICTIM_DOMAIN + ":3000/demos/basic.html"

# Credentials
BEEF_USER = ENV["TEST_BEEF_USER"] || 'beef'
BEEF_PASSWD = ENV["TEST_BEEF_PASS"] || "beef"

# RESTful API root endpoints
RESTAPI_HOOKS = "http://" + ATTACK_DOMAIN + ":3000/api/hooks"
RESTAPI_LOGS = "http://" + ATTACK_DOMAIN + ":3000/api/logs"
RESTAPI_MODULES = "http://" + ATTACK_DOMAIN + ":3000/api/modules"
RESTAPI_NETWORK = "http://" + ATTACK_DOMAIN + ":3000/api/network"
RESTAPI_PROXY = "http://" + ATTACK_DOMAIN + ":3000/api/proxy"
RESTAPI_DNS = "http://" + ATTACK_DOMAIN + ":3000/api/dns"
RESTAPI_SENG = "http://" + ATTACK_DOMAIN + ":3000/api/seng"
RESTAPI_ADMIN = "http://" + ATTACK_DOMAIN + ":3000/api/admin"
RESTAPI_WEBRTC = "http://" + ATTACK_DOMAIN + ":3000/api/webrtc"
