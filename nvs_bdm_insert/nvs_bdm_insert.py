#! /usr/bin/python

import binascii
import datetime
import json

from lxml import etree

# NBS configs
TITLES = ["volumeId", "projectId", "instanceId", "device", "iotune_total_iops", "iotune_total_bytes"]
NBS_EXPORT_FILE = "./nbs_attached_vols.csv"
dmNamePrefix = "ebsdisk01"
HOST_DEV_PREFIX = "/dev/mapper/"

# VM xml config
BLOCK_DISK_XML = "./nbs_disks.xml"

# check title
def check_title(first_line):
    titles = first_line.replace('\n', '').split(',')
    count = 0
    for t in titles:
        if t != TITLES[count]:
            print "ERROR: Sequence of cloumns may be error"
            print "expected: %s" % TITLES
            print "given: %s" % titles
            exit()
        count += 1


def read_xml():
    with open(BLOCK_DISK_XML, 'r') as f:
        return f.read()


# check xml format
def check_xml(xml_doc):
    try:
        return etree.fromstring(xml_doc)
    except Exception:
        print "ERROR: xml format may be error, cannot be parsed"
        exit()


def get_host_dev(projectId, volumeId):
    crc = binascii.crc32('%s_%s_%s' % (dmNamePrefix, projectId, volumeId))
    if crc < 0:
        crc = 2**32 + crc
    return "%s%s_%s_%s_%d" % (HOST_DEV_PREFIX, dmNamePrefix, projectId, volumeId, crc)


def get_slot_target(instance_uuid, host_dev, xml_root):
    doms = xml_root.findall('domain')
    for dom in doms:
        if dom.find('uuid').text == instance_uuid:
            disks = dom.findall('disk')
            for disk in disks:
                if disk.attrib['type'] != 'block':
                    print "WARN: disk type error of instance %s" % instance_uuid
                    continue
                if disk.find('source').attrib.get('dev') == host_dev:
                    return (int(disk.find("address").attrib.get('slot'), 16),
                            disk.find('target').attrib.get('dev'))

    return (None, None)

if __name__ == "__main__":
    # open and read nbs data element.
    with open(NBS_EXPORT_FILE, 'r') as nbs_file:
        attached_vols = nbs_file.readlines()

    check_title(attached_vols[0])
    xml_doc = read_xml()
    xml_root = check_xml(xml_doc)

    with open('./nvs_bdm_insert.sql', 'w') as f:
        for vol in attached_vols[1:]:
            vol = vol.replace('\n', '')
            vol_infos = vol.split(',')
            vol_id = int(vol_infos[0])
            project_id = vol_infos[1]
            instance_uuid = vol_infos[2]
            real_path = vol_infos[3]
            iotune_total_iops = vol_infos[4]
            iotune_total_bytes = vol_infos[5]
            host_dev = get_host_dev(project_id, vol_id)
            if not vol_id or not project_id or not instance_uuid or not real_path or not host_dev:
                print "ERROR: volume %s miss paras" % vol
                continue

            slot, target_dev = get_slot_target(instance_uuid, host_dev, xml_root)
            if not slot or not target_dev:
                print "ERROR: volume %s of instance %s is not found, slot %s, target %s" % (vol, instance_uuid, slot, target_dev)
                continue

            dt = datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")
            device_name = json.dumps({"slot": slot, "mountpoint": "/dev/" + target_dev, "real_path": real_path})
            qos_info = {}
            if iotune_total_iops:
                qos_info.update(iotune_total_iops=int(iotune_total_iops))
            if iotune_total_bytes:
                qos_info.update(iotune_total_bytes=int(iotune_total_bytes))
            if qos_info == {}:
                print "WARN: volume %s miss qos info" % vol
            connection_info = json.dumps({"host_dev": host_dev, "qos_info": qos_info})
            uuid = instance_uuid

            sql = ("INSERT INTO `block_device_mapping` "
                   "(`created_at`, `updated_at`, `deleted`, `delete_on_termination`, `device_name`, `volume_id`, `connection_info`, `instance_uuid`) "
                   "VALUES ('%(dt)s', '%(dt)s', 0, 0, '%(device_name)s', '%(vol_id)s', '%(connection_info)s', '%(uuid)s');\n" % locals())
            f.write(sql)
            print "INFO: handle volume %s OK" % vol



