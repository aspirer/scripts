#!/usr/bin/python

from operator import itemgetter
import datetime
import json
import sys

# ecus usage of flavor
ecus_usage_by_flavor={
    'xtiny.a' : {'ecus': 1,
                 'vcpus': 1,
                 'ecus_per_vcpu': 1},
    'xtiny.b' : {'ecus': 1,
                 'vcpus': 1,
                 'ecus_per_vcpu': 1},
    'xtiny.c' : {'ecus': 1,
                 'vcpus': 1,
                 'ecus_per_vcpu': 1},
    'tiny.a'  : {'ecus': 2,
                 'vcpus': 1,
                 'ecus_per_vcpu': 2},
    'tiny.b'  : {'ecus': 2,
                 'vcpus': 1,
                 'ecus_per_vcpu': 2},
    'tiny.c'  : {'ecus': 2,
                 'vcpus': 1,
                 'ecus_per_vcpu': 2},
    'tiny.d'  : {'ecus': 2,
                 'vcpus': 1,
                 'ecus_per_vcpu': 2},
    'tiny.e'  : {'ecus': 2,
                 'vcpus': 1,
                 'ecus_per_vcpu': 2},
    'tiny.f'  : {'ecus': 2,
                 'vcpus': 1,
                 'ecus_per_vcpu': 2},
    'small.a' : {'ecus': 4,
                 'vcpus': 2,
                 'ecus_per_vcpu': 2},
    'small.b' : {'ecus': 4,
                 'vcpus': 2,
                 'ecus_per_vcpu': 2},
    'small.c' : {'ecus': 4,
                 'vcpus': 2,
                 'ecus_per_vcpu': 2},
    'medium.a': {'ecus': 8,
                 'vcpus': 4,
                 'ecus_per_vcpu': 2},
    'medium.b': {'ecus': 8,
                 'vcpus': 4,
                 'ecus_per_vcpu': 2},
    'medium.c': {'ecus': 8,
                 'vcpus': 4,
                 'ecus_per_vcpu': 2},
    'large.a' : {'ecus': 16,
                 'vcpus': 4,
                 'ecus_per_vcpu': 4},
    'large.b' : {'ecus': 16,
                 'vcpus': 4,
                 'ecus_per_vcpu': 4},
    'large.c' : {'ecus': 16,
                 'vcpus': 4,
                 'ecus_per_vcpu': 4},
    'xlarge.a': {'ecus': 32,
                 'vcpus': 8,
                 'ecus_per_vcpu': 4},
    'xlarge.b': {'ecus': 32,
                 'vcpus': 8,
                 'ecus_per_vcpu': 4},
    'xlarge.c': {'ecus': 32,
                 'vcpus': 8,
                 'ecus_per_vcpu': 4},
    'm1.tiny':  {'ecus': 1,
                 'vcpus': 1,
                 'ecus_per_vcpu': 1},
    'm1.small': {'ecus': 2,
                 'vcpus': 1,
                 'ecus_per_vcpu': 2},
    'm1.medium':{'ecus': 8,
                 'vcpus': 2,
                 'ecus_per_vcpu': 4},
    'm1.large': {'ecus': 16,
                 'vcpus': 4,
                 'ecus_per_vcpu': 4},
    'm1.xlarge':{'ecus': 32,
                 'vcpus': 4,
                 'ecus_per_vcpu': 8},
}

reserved_host_cpus = 4
total_host_cpus = 32
current_using_host_cpu = reserved_host_cpus
ecus_ratio = 4

host_cpu_info = [{"used_ecus": 0, "id": id}
                  for id in range(reserved_host_cpus, total_host_cpus)]
host_cpu_info = sorted(host_cpu_info, key=itemgetter("id"))

# [{"ecu_usage": 4, "id": 1, "vcpu_set": [0]},
#  {"ecu_usage": 4, "id": 2, "vcpu_set": [1]}]
def calc_cpu_pin_relationship(flavor, uuid):
    cpu_pin_relationship = []
    if flavor not in ecus_usage_by_flavor:
        print "\nflavor %s not found, uuid %s\n" % (flavor, uuid)
        return cpu_pin_relationship

    detail = ecus_usage_by_flavor[flavor]
    if detail['ecus'] > sum([ecus_ratio - cpu["used_ecus"]
                            for cpu in host_cpu_info]):
        print "\nhost cpus not enough for %s(%s)!\n" % (uuid, flavor)
        return cpu_pin_relationship

    ecus_per_vcpu = detail['ecus_per_vcpu']
    vcpu_id = 0
    ecus_used = 0
    #import ipdb;ipdb.set_trace()
    for cpu in host_cpu_info:
        support_vcpus = (ecus_ratio - cpu["used_ecus"]) / ecus_per_vcpu
        if support_vcpus <= 0:
            continue
        cpu_set = {}
        vcpu_set = []
        while vcpu_id < detail["vcpus"] and support_vcpus > 0:
            vcpu_set.append(vcpu_id)
            vcpu_id += 1
            support_vcpus -= 1
            cpu["used_ecus"] += ecus_per_vcpu
            ecus_used += ecus_per_vcpu
        cpu_set["ecu_usage"] = len(vcpu_set) * ecus_per_vcpu
        cpu_set["id"] = cpu["id"]
        cpu_set["vcpu_set"] = vcpu_set
        cpu_pin_relationship.append(cpu_set)
        if vcpu_id >= detail["vcpus"]:
            break
    if ecus_used != detail['ecus']:
        print "\n%s(%s) cpu_pin_relationship calc ERROR!\n" % (uuid, flavor)
    else:
        print "%s(%s) cpu_pin_relationship calc OK" % (uuid, flavor)
    return json.dumps(cpu_pin_relationship)

def _check_ecus_usage_by_flavor():
    for flavor, usage in ecus_usage_by_flavor.iteritems():
        print "checking %s usage: %s" % (flavor, usage)
        if usage['ecus'] != usage['vcpus'] * usage['ecus_per_vcpu']:
            print "\n%s ecus usage error!\n" % flavor


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print "arg [instance_list] needed!"
        exit(1)
    else:
        instances_file = sys.argv[1]
    _check_ecus_usage_by_flavor()

    # test
    flavors = [flavor for flavor in ecus_usage_by_flavor.keys()]
    uuids = ["uuid-%04d" % id for id in range(1, len(flavors) + 1)]

    # print uuids, flavors
    # print host_cpu_info
    # print "---------------------------------------------"
    # for i in range(0, len(flavors)):
        # print "calc cpu_pin_relationship for %s(%s)" % (uuids[i], flavors[i])
        # cpu_pin_relationship = calc_cpu_pin_relationship(flavors[i], uuids[i])
        # print "==== '%s' ====" % cpu_pin_relationship
        # # print host_cpu_info
    # print "---------------------------------------------"
    # cpu_pin_relationship = calc_cpu_pin_relationship('test-flavor', 'test-uuid')
    # print "==== '%s' ====" % cpu_pin_relationship

    instances = []
    lines = []
    with open(instances_file, 'r') as f:
        lines = f.readlines()
    print lines
    for line in lines:
        line = line.replace(' ', '').replace('\r', '').replace('\n', '')
        instance = line.split(',')
        print instance
        uuid = instance[0]
        flavor = instance[4]
        instances.append({"uuid": uuid, "flavor": flavor})

    print instances

    print "---------------------------------------------"
    sql_file = './' + instances_file.rsplit('.', 1)[0] + '_cpuqos.sql'
    with open(sql_file, 'w') as f:
        for ins in instances:
            print "calc cpu_pin_relationship for %s(%s)" % \
                    (ins['uuid'], ins['flavor'])
            cpu_pin_relationship = \
                    calc_cpu_pin_relationship(ins['flavor'], ins['uuid'])
            if cpu_pin_relationship == []:
                continue
            dt = datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")
            deleted = 0
            uuid = ins['uuid']
            key = 'cpu_pin_relationship'
            value = cpu_pin_relationship
            sql = ("INSERT INTO `instance_system_metadata_extension` "
                  "(`created_at`, `deleted`, `instance_uuid`, `key`, `value`) "
                  "VALUES ('%(dt)s', '%(deleted)s', '%(uuid)s', '%(key)s', "
                  "'%(value)s');\n" % locals())
            f.write(sql)
    print "---------------------------------------------"
