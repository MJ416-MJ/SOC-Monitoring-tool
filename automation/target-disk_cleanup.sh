#!/bin/bash
journalctl --vacuum-size=200M
find /var/log -name '*.gz' -mtime +7 -delete
rm -f /var/fill.img
