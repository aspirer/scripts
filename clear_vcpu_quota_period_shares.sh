#! /bin/bash
for ins in `sudo virsh list --all | grep instance | awk '{print $2}'`
do
    echo "clearing instance ${ins}"
    sudo virsh schedinfo ${ins} --set cpu_shares=0 vcpu_period=0 vcpu_quota=0 --config
    sudo virsh schedinfo ${ins} --set cpu_shares=1024 vcpu_period=0 vcpu_quota=-1 --live
    sleep 1
done
