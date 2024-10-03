#! /bin/bash
export DOCUMENT_ROOT=/home/s2e
export SCRIPT_FILENAME=/home/s2e/test.php
export REQUEST_METHOD=GET
export QUERY_STRING=""
export REQUEST_URI="/test.php"
export SERVER_NAME=localhost
export SERVER_PORT=80
export SERVER_PROTOCOL=HTTP/1.1
export SERVER_SOFTWARE="Apache"
export REMOTE_ADDR=127.0.0.1
export REMOTE_PORT=12345
export HTTP_USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.99 Safari/537.36"
export HTTP_COOKIE=""
export QUERY_STRING="var1=xxxx"
export ENABLE_SYMPHP=1
./php-cgi
