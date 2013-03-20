#! /bin/bash
while [ 1 ]
do
    echo "start ping..."
    ping -c2 -w2 8.8.8.8 >> ping.log
    ping -c2 -w2 www.163.com >> ping.log
    ping -c2 -w2 www.baidu.com >> ping.log
    ping -c2 -w2 10.162.20.65 >> ping.log
    ping -c2 -w2 10.160.20.80 >> ping.log
    ping -c2 -w2 10.160.20.28 >> ping.log
    ping -c2 -w2 10.160.20.29 >> ping.log
    echo "end ping."
    sleep 1
done
