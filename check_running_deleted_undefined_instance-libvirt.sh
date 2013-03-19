#!/bin/bash
# 需要运行在被检查的宿主机上，并且宿主机上要可以使用admin权限的nova命令行进行nova show操作！

host=`hostname`
dt=`date +%m_%d-%H_%M_%S`
if [ -f ./checklist_${host}_uuids-OK.csv ];then
    mv ./checklist_${host}_uuids-OK.csv ./checklist_${host}_uuids-OK_${dt}.csv
fi
if [ -f ./checklist_${host}_uuids_hostchanged-need2delete.csv ];then
    mv ./checklist_${host}_uuids_hostchanged-need2delete.csv ./checklist_${host}_uuids_hostchanged-need2delete_${dt}.csv
fi
if [ -f ./checklist_${host}_uuids_deleted-need2delete.csv ];then
    mv ./checklist_${host}_uuids_deleted-need2delete.csv ./checklist_${host}_uuids_deleted-need2delete_${dt}.csv
fi

echo "checking all instances which is managed by libvirt whether still in DB or not"
for uuid in `sudo virsh list --all --uuid`
{
    echo "checking instance ${uuid}"
    host_match=`nova show ${uuid} | grep "OS-EXT-SRV-ATTR:host" | grep -o "${host}"`
    running_on=`nova show ${uuid} | grep -w "OS-EXT-SRV-ATTR:host" | awk '{print $4}'`
    if [ ${host_match} ];then
        echo -e "-->${uuid} is running in DB<--\t\t\t\tOK"
        echo ${uuid} >> checklist_${host}_uuids-OK.csv
    elif [ ${running_on} ];then
        echo -e "-->${uuid} is running in DB but not on this host(running on ${running_on})<--\t\t\t\tWARNING!"
        echo ${uuid} >> checklist_${host}_uuids_hostchanged-need2delete.csv
    else
        echo -e "-->${uuid} isn't running in DB<--\t\t\t\tERROR!!"
        echo ${uuid} >> checklist_${host}_uuids_deleted-need2delete.csv
    fi
}