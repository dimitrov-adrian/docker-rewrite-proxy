#!/bin/bash
. .env
docker-compose up -d
sleep 2

# Usage: <domain> <name>
function testaccess() {
    echo
    echo -ne "Check $2 on $1 "
    response=$(curl -s -L --resolve "$1:$HTTP_PORT:127.0.0.1" "$1:$HTTP_PORT")
    if [ -z "$(echo "$response" | grep "Server name: $2")" ]; then
        echo -ne "ERROR"
        echo $response
        exit 1
    else
        echo -ne "OK"
    fi
}

testaccess "bew1.example.com" "web-1"
testaccess "bewaaaa.example.com" "web-1"
testaccess "bew.example.org" "web-1"
testaccess "bew.example.org" "web-1"
testaccess "bewABCD1.example.org" "web-1"
testaccess "web1.org" "web-1"
testaccess "web2.org" "web-2"
testaccess "web3.org" "web-3"
testaccess "aa.web1.org" "web-1"
testaccess "aa.web2.org" "web-2"
testaccess "aa.b.web1.org" "web-1"
testaccess "aa.b.c.web1.org" "web-1"
testaccess "aa.b.c.d.e.web1.org" "web-1"
testaccess "z.b.c.d.e.web1.org" "fallback"
testaccess "zmmmm.org" "fallback"
testaccess "localhost" "fallback"
testaccess "directhost-web-1" "web-1"
testaccess "directhost-web-2" "web-2"
testaccess "directhost-web-3" "web-3"

#docker-compose down
