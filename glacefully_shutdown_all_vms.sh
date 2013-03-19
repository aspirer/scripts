#!/bin/bash
# gracefully shutdown all vms.
for vm in `sudo virsh list | grep 'instance' | awk '{print $2}'`
do
    echo "shutting down vm: $vm"
    sudo virsh shutdown $vm
    sleep 1
done

echo "please wait 5 minutes for all vms shuttoff..."

for ((i=0;i<30;i++))
do
    running=`sudo virsh list | grep 'running' | awk '{print $2}'`
    if [ "$running"x != ""x ];then
        echo "running vms:"
        echo $running
        echo "sleep 10s and check again..."
        sleep 10
    else
        break
    fi
done

running=`sudo virsh list | grep 'running' | awk '{print $2}'`
if [ "$running"x != ""x ];then
    echo "after waitting for 5 minutes, still running vms:"
    echo $running
    echo "please login to these vms and shutdown them manually"
else
    echo "all vms is shutdown now"
    sudo virsh list --all
fi