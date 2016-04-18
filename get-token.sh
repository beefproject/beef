#!/bin/bash

PORT=$(cat config.yaml | grep "HTTP server" -A4 | grep port | egrep -o '"([0-9]+)"' | tr -d '"')
JSON=$(echo "{"$(cat config.yaml | grep "Credentials to authenticate in BeEF." -A4 | egrep "user|passwd" | sed 's/user/"username"/' | sed 's/passwd/"password"/' | sed 'N;s/\n/,/' | sed -r 's/:\s+/:/' | sed -r 's/",\s+"/","/')"}" | sed -r 's/":\s*"/":"/g' | sed 's/{ "/{"/' )

curl -sk -H "Content-Type: text/json" -d $JSON http://127.0.0.1:${PORT}/api/admin/login | jq '. .token' | tr -d '"'
