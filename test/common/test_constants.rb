#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
BEEF_TEST_DIR = "/tmp/beef-test/"

# General constants
ATTACK_DOMAIN = "attacker.beefproject.com"
VICTIM_DOMAIN = "attacker.beefproject.com"
ATTACK_URL = "http://" + ATTACK_DOMAIN + ":3000/ui/panel"
VICTIM_URL = "http://" + VICTIM_DOMAIN + ":3000/demos/basic.html"

# Credentials
BEEF_USER = "beef"
BEEF_PASSWD = "beef"

# RESTful API root endpoints
RESTAPI_HOOKS = "http://" + ATTACK_DOMAIN + ":3000/api/hooks"
RESTAPI_LOGS = "http://" + ATTACK_DOMAIN + ":3000/api/logs"
RESTAPI_MODULES = "http://" + ATTACK_DOMAIN + ":3000/api/modules"
RESTAPI_ADMIN = "http://" + ATTACK_DOMAIN + ":3000/api/admin"