pkill keystone
pkill glance
pkill nova
pkill cinder
sleep 2

keystone-all > /opt/stack/log/key.log &

glance-registry > /opt/stack/log/g-reg.log &
glance-api > /opt/stack/log/g-api.log &

nova-api-os-compute > /opt/stack/log/n-os-api.log &
nova-scheduler > /opt/stack/log/n-sch.log &
nova-compute > /opt/stack/log/n-cpu.log &
nova-conductor > /opt/stack/log/n-con.log &

cinder-api > /opt/stack/log/c-api.log &
cinder-scheduler > /opt/stack/log/c-sch.log &
cinder-volume > /opt/stack/log/c-vol.log &
