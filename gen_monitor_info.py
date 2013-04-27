#! /usr/bin/python
import json
import os
import time

pf_keys = {}
pf_key_file = "./input_dir/pf_key_file.csv"

with open(pf_key_file, 'r') as pff:
    pfk_info = pff.readlines()
for info_line in pfk_info:
    info = info_line.split()
    tenant = info[0]
    key = info[1]
    secret = info[2]
    pf_keys[tenant] = [key, secret]
print pf_keys

info_content = {"service": "openstack",
                "ori_user": None,
                "resource_type":"openstack",
                "resource_id": "",
                "aggregation_items":{},
                "accessKey": None,
                "accessSecret": None,
                "monitorWebServerUrl":"http://10.120.39.245:8181"
                }

vm_info_file = "./input_dir/vm_list.csv"
info_output_dir = "./monitor_info"
if os.path.exists(info_output_dir):
    print "output dir is already exists: %s" % info_output_dir
    exit(1)
os.mkdir(info_output_dir)

with open(vm_info_file, 'r') as vf:
    vm_list = vf.readlines()

i = 1
for vm in vm_list:
    print "---------line %d------------\n" % i
    print vm
    vm_infos = vm.split()
    vm_host_name = vm_infos[3]
    if 'rds' in vm_host_name:
        print "ignore rds vm %s" % vm_host_name
        continue

    vm_tenant = vm_infos[2]
    vm_ip = vm_infos[7]
    if not os.path.exists(os.path.join(info_output_dir, vm_tenant)):
        os.mkdir(os.path.join(info_output_dir, vm_tenant))
        info_content["ori_user"] = vm_tenant
        info_content["accessKey"] = pf_keys[vm_tenant][0]
        info_content["accessSecret"] = pf_keys[vm_tenant][1]
        print info_content
        with open(os.path.join(info_output_dir, vm_tenant, "info"), 'w') \
                as info_file:
            info_file.write(json.dumps(info_content))
    with open(os.path.join(info_output_dir, vm_tenant, "host_list"), 'a') \
            as host_list:
        host_list.write(vm_host_name + "\t" + vm_ip + "\n")
    i += 1
