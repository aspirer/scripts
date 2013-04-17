#!/bin/bash
# hostname ; grep 'periodic task' /data/log/nova/nova-compute.log | tail -n1; echo
for i in `seq 11 13`; do ssh -p1046 114.113.199.$i "hostname ; grep 'periodic task' /data/log/nova/nova-compute.log | tail -n1; echo"; done
