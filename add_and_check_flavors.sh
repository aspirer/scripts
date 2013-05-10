#!/bin/bash

# author: hzguanqiang, hzwangpan
# date  : 2013-05-08
# See http://jira.hz.netease.com/browse/CLOUD-4537 for more details
# Adding all flavors to nova DB by nova-manage,
# and then checking it by diff the log file and result file

ecus=(1 2 4 6 8 12 16 24 32)
mems=(512 1024 2048 4096 6144 8192 12288 16384 24576 32768)
ephemeral_disks=(0 10 20 30 40 60 80 120 160 200)
local_disk=20
id=1

# find the biggest flavor_id in database.
flavor_id=`sudo nova-manage flavor list | awk -F, '{print $5}' | awk  '{print $2}' | sort -n | tail -n1`
if [ "${flavor_id}s" == "s" ]
then
    flavor_id=0
fi
flavor_id=`expr $flavor_id + 1`

# when creating a new flavor, the flavor info will be witten into file 'add_flavor_list' by the following order.
echo id,name,mem,disk,ephemeral_disk,vcpu,ecu > add_flavor_list

# the ecu for sentence is to traverse the 9 given ecu configure.
for ecu in ${ecus[@]}
do
    # the following case sentences are to give the vcpu number and ecus_per_vcpu value for each ecu configure.
    case $ecu in
        1)    vcpu=1
              ecus_per_vcpu=1;;
        2)    vcpu=1
              ecus_per_vcpu=2;;
        4)    vcpu=2
              ecus_per_vcpu=2;;
        6)    vcpu=2
              ecus_per_vcpu=3;;
        8)    vcpu=4
              ecus_per_vcpu=2;;
        12)   vcpu=4
              ecus_per_vcpu=3;;
        16)   vcpu=4
              ecus_per_vcpu=4;;
        24)   vcpu=6
              ecus_per_vcpu=4;;
        32)   vcpu=8
              ecus_per_vcpu=4
    esac

    # the mem for sentence is to traverse the 10 given memory configure.
    for mem in ${mems[@]}
    do

        # the ephemeral_disk for sentence is to traverse the 10 given ephemeral_disk configure.
        for ephemeral_disk in ${ephemeral_disks[@]}
        do
            # the following if sentence is to abandon some unreasonable ecus and memory combination.
            ecus_per_128Mmem=`expr $ecu \* 8192 / $mem`
            if [ "$ecus_per_128Mmem" -lt "1" -o "$ecus_per_128Mmem" -gt "64" ]
            then
                continue
            fi

            # the following echo is to record flavor_info added into db in file 'add_flavor_list'.
            echo ${flavor_id},flavor_${id},${mem},${local_disk},${ephemeral_disk},${vcpu},${ecus_per_vcpu} >> add_flavor_list

            # the following is to create a flavor.
            echo nova-manage flavor create --name=flavor_${id} --flavor=$flavor_id --memory=$mem --root_gb=$local_disk --cpu=$vcpu --ephemeral_gb=$ephemeral_disk
            sudo nova-manage flavor create --name=flavor_${id} --flavor=$flavor_id --memory=$mem --root_gb=$local_disk --cpu=$vcpu --ephemeral_gb=$ephemeral_disk

            # the following is to set ecu configure for a flavor.
            echo nova-manage flavor set_key --name=flavor_${id} --key=ecus_per_vcpu: --value=$ecus_per_vcpu
            sudo nova-manage flavor set_key --name=flavor_${id} --key=ecus_per_vcpu: --value=$ecus_per_vcpu
            echo
            id=`expr $id + 1`
            flavor_id=`expr $flavor_id + 1`
        done
    done
done

# check added flavors
sudo nova-manage flavor list | grep flavor_ | sed "s/:\|,\|MB\|GB\|Gb\|u'\|'}//g" | awk '{print $11","$1","$3","$7","$9","$5","$20}' > flavor_add_result
echo id,name,mem,disk,ephemeral_disk,vcpu,ecu > sorted_flavor_result
sort -t"," -n -k1 flavor_add_result >> sorted_flavor_result

if [ ! -f add_flavor_list ] || [ ! -f sorted_flavor_result ]
then
    echo add_flavor_list or sorted_flavor_result file not found!
    exit 1
fi

# diff the flavors in log file and result file
diff=`diff sorted_flavor_result add_flavor_list`
if [ "${diff}s" != "s" ]
then
        echo flavors create failed!
        exit 1
else
        echo flavors create succeed!
fi

rm -f add_flavor_list flavor_add_result sorted_flavor_result
