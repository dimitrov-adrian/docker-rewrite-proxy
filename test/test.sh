#!/bin/bash
. .env
docker-compose up -d --build
sleep 2

# Usage: <domain> <name>
function testaccess() {
    echo
    echo -ne "Check $2 on $1 "
    response=$(curl -s -L --resolve "$1:$HTTP_PORT:127.0.0.1" "$1:$HTTP_PORT")
    if [ -z "$(echo "$response" | grep "DNS lookup failure for: $2")" ]; then
        echo -ne "ERROR"
        echo $response
        exit 1
    else
        echo -ne "OK"
    fi
}

testaccess "bew1.example.com" "web1"
testaccess "bewaaaa.example.com" "web1"
testaccess "bew.example.org" "web1"
testaccess "bew.example.org" "web1"
testaccess "bewABCD1.example.org" "web1"
testaccess "web1.org" "web1"
testaccess "web2.org" "web2"
testaccess "web3.org" "web3"
testaccess "aa.web1.org" "web1"
testaccess "aa.web2.org" "web2"
testaccess "aa.b.web1.org" "web1"
testaccess "aa.b.c.web1.org" "web1"
testaccess "aa.b.c.d.e.web1.org" "web1"
testaccess "z.b.c.d.e.web1.org" "fallback"
testaccess "zmmmm.org" "fallback"
testaccess "localhost" "fallback"
testaccess "directhost-web-1" "web-1"
testaccess "directhost-web-2" "web-2"
testaccess "directhost-web-3" "web-3"

#docker-compose down
