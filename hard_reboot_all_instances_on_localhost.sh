#!/bin/bash
# 需要运行在被操作的宿主机上，并且宿主机上要可以使用admin权限的nova命令行进行nova reboot操作！

running=`sudo virsh list | grep 'running' | awk '{print $2}'`
if [ "$running"x != ""x ];then
    echo "still running vms:"
    echo $running
    echo "please shutdown them firstly"
    exit 1
else
    echo "all vms is shutdown now"
    sudo virsh list --all
fi

echo "going to hard reboot all instances on this host"
for uuid in `sudo virsh list --all --uuid`
{
    echo "undefine instance ${uuid} now"
    sudo virsh undefine ${uuid}
    echo "hard reboot instance ${uuid} now"
    nova reboot --hard ${uuid}
    sleep 1
}

echo "please wait for all instances reboot end"
