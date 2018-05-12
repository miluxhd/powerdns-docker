#!/bin/sh

mkdir /run/php
supervisord -c /etc/supervisor/supervisord.conf

