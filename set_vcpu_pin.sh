#! /bin/bash
# change vcpupin
if [ "$1" ];then
    reserve=$1
else
    reserve=4
fi
echo "reserved cpu=${reserve}"

pcpus=`cat /sys/devices/system/cpu/online | awk -F\- '{print $2}'`
echo "pcpu num=${pcpus}"
for ins in `sudo virsh list --all | grep "instance" | awk '{print $2}'`
do
    echo "instance ${ins}"
    vcpus=`sudo virsh vcpucount ${ins} 2>/dev/null | grep current | grep config | awk '{print $3}'`
    echo "vcpu num=${vcpus}"
    for((i=0;i<${vcpus};i++))
    {
        echo "change vcpu$i"
        sudo virsh vcpupin ${ins} $i ${reserve}-${pcpus} --live 2>/dev/null
        sudo virsh vcpupin ${ins} $i ${reserve}-${pcpus} --config 2>/dev/null
    }
    echo "check instance ${ins}"
    res=`sudo virsh dumpxml ${ins} | grep cpuset`
    echo "vcpupin result: ${res}"
    if [ "${res}"x = ""x ]
    then
        echo -e "\t\t\t\t\t\t\t\t\t\t\t ${ins}: ERROR!"
    else
        echo -e "\t\t\t\t\t\t\t\t\t\t\t ${ins}: OK!"
    fi
done
