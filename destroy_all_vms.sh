#!/bin/bash
# forcibly shutdown all vms.

echo "destroy all vms is a risky operation!"
echo "are you sure to implement?[yes|no]:"
read ans
while [[ "$ans"x != "yes"x && "$ans"x != "no"x ]]
do
    echo "please type 'yes' or 'no':"
    read ans
done

if [ "$ans"x != "yes"x ];then
    echo "exit now"
    exit 0
fi

echo "WARNING: going to destroy all vms now!"
sleep 5

for vm in `sudo virsh list | grep 'instance' | awk '{print $2}'`
do
    echo "destroy vm: $vm"
    sudo virsh destroy $vm
    sleep 1
done

echo "all vms is shutdown now"
sudo virsh list --all
