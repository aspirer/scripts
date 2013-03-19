#!/bin/bash

host=$1
if [ ! ${host} ];then
    echo "arg [host] needed!"
    exit
fi
echo -e "get all instances info on host $host now\n"
dt=`date +%m_%d-%H_%M_%S`
if [ -f ./checklist_${host}.csv ];then
    mv ./checklist_${host}.csv ./checklist_${host}_${dt}.csv
fi

private_fixed_ip=10.120.34.
private_floating_ip=10.120.240.
public_floating_ip=114.113.199.


function get_uuid()
{
    uuid=`grep -w "id" ./ins_details.tmp | awk '{print $4}'`
    echo -n "$uuid," >> ./checklist_${host}.csv
}

function get_ips()
{
    ips=`grep "private network" ./ins_details.tmp | awk -F'|' '{print $3}'`
    pri_fixed_ip=`echo $ips | grep -o "$private_fixed_ip[1-9][0-9]\{0,2\}"`
    pri_float_ip=`echo $ips | grep -o "$private_floating_ip[1-9][0-9]\{0,2\}"`
    pub_float_ip=`echo $ips | grep -o "$public_floating_ip[1-9][0-9]\{0,2\}"`
    echo -n "$pri_fixed_ip,$pri_float_ip,$pub_float_ip," >> ./checklist_${host}.csv
}

function get_flavor()
{
    flavor=`grep "flavor" ./ins_details.tmp | awk '{print $4$5}'`
    echo "$flavor," >> ./checklist_${host}.csv
}


i=0
for ins in `nova list --all-tenants | grep -v "ID" | grep -v "\-\-\-\-\-" | awk '{print $2}'`
{
    echo "checking instance: $ins now";
    nova show $ins > ./ins_details.tmp;
    host_match=`grep "OS-EXT-SRV-ATTR:host" ./ins_details.tmp | grep -o "$host"`
    if [ ${host_match} ];then
        echo "-->$ins is running on $host<--"
        ((i++))
        get_uuid
        get_ips
        get_flavor
    fi
}
echo "find $i instances on host $host"
rm -f ./ins_details.tmp


