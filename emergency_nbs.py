#! /usr/bin/python

import httplib
import json
from lxml import etree
import os
import sys
import time

import libvirt


NBS_PREFIX_URL = '/EBS'
DISKXML = '''<disk type='block' device='disk'>
    <driver name='qemu' type='raw' cache='none'/>
    <source dev='%s'/>
    <target dev='%s' bus='virtio'/>
    <serial>%s</serial>
    <address type='pci' domain='0x0000' bus='0x00' slot='0x%0.2x' function='0x0'/>
</disk>'''


def _request(nbs_api_server, url):
    """The essential implement of nbs api client."""
    headers = {"Content-type": "application/json",
               "Accept": "application/json"}
    params = None
    method = "GET"

    if not nbs_api_server:
        print "nbs_api_server is null, can't connect to it"
        exit()

    full_url = nbs_api_server + url

    print ("send request to %(full_url)s, method: %(method)s, "
               "body: %(params)s, headers: %(headers)s" %
               {"full_url": full_url, "method": method,
                  "params": params, "headers": headers})
    try:
        nbs_conn = httplib.HTTPConnection(nbs_api_server)
    except Exception as ex:
        print ("exception occurs when connect to nbs server, "
                    "error msg: %s" % str(ex))
        exit()

    try:
        nbs_conn.request(method, url, params, headers)
        resp = nbs_conn.getresponse()
        if resp:
            if resp.status == 200:
                data = json.loads(resp.read())
                request_id = data["requestId"]
                print ("request id: %(request_id)s, data: %(data)s" %
                        {"request_id": request_id, "data": data})
                return data
            else:
                err_code = resp.status
                err_reason = resp.reason
                print ("error occurs when contact to nbs server, "
                            "error code: %(code)d, reason: %(reason)s"
                            % {"code": err_code, "reason": err_reason})
                exit()
        else:
            print "nbs server doesn't return any response"
            exit()

    except Exception as ex:
        print ("exception occurs when send request to nbs server, "
                    "error msg: %s" % str(ex))
        exit()
    finally:
        nbs_conn.close()


def list_vols(kwargs):
    """Get volume detail by calling nbs DescribeVolumes api."""
    if len(kwargs) < 2:
        print_usage('list')
        exit()

    url = (NBS_PREFIX_URL + "/?Action=DescribeVolumes"
            + "&ProjectId=" + str(kwargs['project_id']))
    if kwargs.get('volume_id'):
        url += ("&VolumeId=" + str(kwargs['volume_id']))
    if kwargs.get('instance_id'):
        url += ("&InstanceId=" + str(kwargs['instance_id']))

    vols = _request(kwargs['nbs_api_server'], url)
    return vols


def wait_for_attached(kwargs):
    """
    Wait for nbs finished to attach the volume to host by checking status.
    """
    # FIXME(wangpan): How to deal with the timeout situation?
    start = time.time()
    times = 1
    while (time.time() - start < 300):
        # FIXME(wangpan): we just deal with single attachment status now
        try:
            volume = list_vols(kwargs)["volumes"][0]
        except (IndexError, KeyError, TypeError):
            print ("Get nothing from nbs server, sleep %(interval)ds "
                       "and retry, times: %(times)d"
                       % {"interval": check_interval, "times": times})
            time.sleep(check_interval)
            times += 1
            continue

        try:
            attachment = volume["attachments"][0]
            if attachment["status"] == "attached":
                return True
        except (IndexError, KeyError, TypeError):
            print ("Get wrong info from nbs server, sleep "
                       "%(interval)ds and retry, times: %(times)d"
                       % {"interval": check_interval, "times": times})

        print ("sleep %(interval)ds and retry to check volume's "
                   "status, times: %(times)d"
                   % {"interval": check_interval, "times": times})
        time.sleep(check_interval)
        times += 1
    print ("volume %(volume)s can not be attached successfully "
               "after %(timeout)ds"
               % {"volume": kwargs['volume_id'],
                  "timeout": 300})
    exit()


def get_libvirt_conn():
    return libvirt.open(None)


def _find_free_dev_and_pcislot(dom):
    dom_xml = dom.XMLDesc(0)
    doc = etree.fromstring(dom_xml)
    devices = doc.findall('./devices/')
    used_pci_slot_ids = []

    for device in devices:
        address = device.find('address')
        if (address is None or len(address.attrib) == 0
                or address.attrib.get('slot') is None):
            continue
        used_pci_slot_ids.append(int(address.attrib['slot'], 16))

    disks = doc.findall('./devices/disk')
    used_disk_devs = [disk.find('target').attrib['dev'] for disk in disks]

    free_slot = None
    free_dev = None

    # slot id range is 0-31(KVM only)
    for id in range(31, 0, -1):
        if id not in used_pci_slot_ids:
            free_slot = id
            break

    prefix = 'vd'

    # vd/sd[d-z], skip root, ephemeral and swap disk
    for i in range(100, 123):
        dev = prefix + chr(i)
        if dev not in used_disk_devs:
            free_dev = dev
            break

    return (free_slot, free_dev)


def _slot_to_disk(slot):
    ascii_table = "abcdefghijklmnopqrstuvwxyz"
    nums = slot * 8
    nbs_disk = ''
    while nums > 0:
        value = nums % 26
        ch = ascii_table[value:value + 1]
        nbs_disk = ch + nbs_disk
        nums = nums / 26
    return nbs_disk


def get_device_for_nbs_volume(dom):
    """Generates a device name for attaching nbs volume."""
    free_slot, free_dev = _find_free_dev_and_pcislot(dom)
    if free_slot is None or free_dev is None:
        return None
    target_dev = '/dev/' + free_dev
    real_path = ('/dev/nbs/xd' + _slot_to_disk(free_slot))

    return {'mountpoint': target_dev,
            'real_path': real_path,
            'slot': free_slot}


def get_host_dev_and_qos_info(kwargs):
    """Get host device and QoS info from nbs server."""
    url = (NBS_PREFIX_URL + "/?Action=GetVolumeQos"
            + "&ProjectId=" + str(kwargs['project_id'])
            + "&VolumeId=" + str(kwargs['volume_id'])
            + "&HostIp=" + str(kwargs['host_ip']))

    result = _request(kwargs['nbs_api_server'], url)
    if result is None:
        print "GetVolumeQos from nbs failed"
        exit()

    host_dev = result.get('devicePath', None)
    if host_dev is None:
        print "host dev get from nbs failed"
        exit()

    iotune_read_bytes = result.get('maxReadBandWidth')
    iotune_write_bytes = result.get('maxWriteBandWidth')
    iotune_read_iops = result.get('maxReadIOPS')
    iotune_write_iops = result.get('maxWriteIOPS')

    qos_info = {}
    if (iotune_read_bytes is not None or
            iotune_write_bytes is not None or
            iotune_read_iops is not None or
            iotune_write_iops is not None):
        if iotune_read_bytes is not None:
            qos_info['iotune_read_bytes'] = int(iotune_read_bytes)
        if iotune_write_bytes is not None:
            qos_info['iotune_write_bytes'] = int(iotune_write_bytes)
        if iotune_read_iops is not None:
            qos_info['iotune_read_iops'] = int(iotune_read_iops)
        if iotune_write_iops is not None:
            qos_info['iotune_write_iops'] = int(iotune_write_iops)
    else:
        print ("Nbs volume %s qos info is missing" % volume_id)

    return (host_dev, qos_info)


def notify_nbs_libvirt_result(kwargs, device, operation, result):
    url = (NBS_PREFIX_URL + "/?Action=NotifyState"
            + "&ProjectId=" + str(kwargs['project_id'])
            + "&VolumeId=" + str(kwargs['volume_id'])
            + "&OperateType=" + operation)

    if operation == "attach":
        url += ("&Device=" + str(device)
                + "&HostIp=" + str(kwargs['host_ip'])
                + "&InstanceId=" + str(kwargs['instance_id']))
    elif operation == "extend":
        url += "&Size=" + str(kwargs['size'])

    if result:
        url += "&OperateState=" + "success"
    else:
        url += "&OperateState=" + "fail"

    return _request(kwargs['nbs_api_server'], url)


def _get_dev_num(host_dev):
    real_dev = os.path.realpath(host_dev)
    sys_dev = os.path.join('/sys/block', os.path.basename(real_dev), 'dev')
    with open(sys_dev) as f:
        dev_num = f.readline()
    dev_num = dev_num.splitlines()[0]

    return dev_num


def attach(kwargs):
    if len(kwargs) != 5:
        print_usage('attach')
        exit()

    url = (NBS_PREFIX_URL + "/?Action=AttachVolume"
                + "&ProjectId=" + str(kwargs['project_id'])
                + "&VolumeId=" + str(kwargs['volume_id'])
                + "&InstanceId=" + str(kwargs['instance_id'])
                + "&HostIp=" + str(kwargs['host_ip']))

    # attach nbs to host
    _request(kwargs['nbs_api_server'], url)

    # wait for nbs appears on the host
    wait_for_attached(kwargs)
    host_dev, qos_info = get_host_dev_and_qos_info(kwargs)

    conn = get_libvirt_conn()
    dom = conn.lookupByUUIDString(kwargs['instance_id'])
    instance_name = dom.name()
    device = get_device_for_nbs_volume(dom)
    url += ("&Device=" + str(device['real_path']))

    # attach nbs to vm now
    try:
        disk_xml = DISKXML % (host_dev, device['mountpoint'].rpartition('/')[2],
                              kwargs['volume_id'],
                              device['slot'])
        print disk_xml
        flags = libvirt.VIR_DOMAIN_AFFECT_CONFIG
        state = dom.info()[0]
        if state == 1:
            flags |= libvirt.VIR_DOMAIN_AFFECT_LIVE
        dom.attachDeviceFlags(disk_xml, flags)
    except Exception as ex:
        print "attach to vm failed: %s" % ex
        notify_nbs_libvirt_result(kwargs, device['real_path'], 'attach', False)
        raise

    # notify nbs attachment succeed
    notify_nbs_libvirt_result(kwargs, device['real_path'], 'attach', True)

    # tell admin change db and qos
    print '\n' + '*' * 100
    print 'you ___MUST___ do these operations now:'
    print '(1) insert block_device_mapping record to nova db block_device_mapping table'
    print '''INSERT INTO `block_device_mapping` (`created_at`, `updated_at`, `deleted_at`, `device_name`, `delete_on_termination`, `snapshot_id`, `volume_id`, `volume_size`, `no_device`, `connection_info`, `instance_uuid`, `deleted`, `source_type`, `destination_type`, `guest_format`, `device_type`, `disk_bus`, `boot_index`, `image_id`) VALUES ('2014-01-01 01:01:01', '2014-01-01 01:01:01', NULL, '{"slot": %s, "mountpoint": "%s", "real_path": "%s"}', 0, NULL, '%s', NULL, NULL, '{"host_dev": "%s", "qos_info": {"iotune_write_bytes": %s, "iotune_read_iops": %s, "iotune_read_bytes": %s, "iotune_write_iops": %s}}', '%s', 0, 'volume', 'volume', NULL, 'disk', NULL, -1, NULL);''' % (device['slot'], device['mountpoint'], device['real_path'], kwargs['volume_id'], host_dev, qos_info['iotune_write_bytes'], qos_info['iotune_read_iops'], qos_info['iotune_read_bytes'], qos_info['iotune_write_iops'], kwargs['instance_id'])
    print "(2) set the nbs volume's qos"
    dev_num = _get_dev_num(host_dev)
    cgroup_path_with_name = os.path.join('/sys/fs/cgroup/blkio/libvirt/qemu', instance_name)
    if not os.path.exists(cgroup_path_with_name):
        cgroup_path_with_name = os.path.join('/sys/fs/cgroup/blkio/machine', instance_name + '.libvirt-qemu')
    if not os.path.exists(cgroup_path_with_name):
        print "ERROR: cgroup blkio dir of instance %s is not found!" % instance_id
        exit()

    print "please run cmd: 'tee %s/blkio.throttle.read_bps_device', then input '%s %s'" % (cgroup_path_with_name, dev_num, qos_info['iotune_read_bytes'])
    print "please run cmd: 'tee %s/blkio.throttle.read_iops_device', then input '%s %s'" % (cgroup_path_with_name, dev_num, qos_info['iotune_read_iops'])
    print "please run cmd: 'tee %s/blkio.throttle.write_bps_device', then input '%s %s'" % (cgroup_path_with_name, dev_num, qos_info['iotune_write_bytes'])
    print "please run cmd: 'tee %s/blkio.throttle.write_iops_device', then input '%s %s'" % (cgroup_path_with_name, dev_num, qos_info['iotune_write_iops'])

    print '*' * 100



def detach(kwargs):
    print args


def updateqos(kwargs):
    print args


def extend(kwargs):
    print args


ACTION_MAP = {
    'list': list_vols,
    'attach': attach,
    'detach': detach,
    'updateqos': updateqos,
    'extend': extend,
    }


helps = {"list": "nbs_api_server:port project_id=xxx [volume_id=yyy] [instance_id=zzz]",
         "attach": "nbs_api_server:port project_id=xxx volume_id=yyy instance_id=zzz host_ip=000(for connecting nbs agent)",}
         #"detach": "nbs_api_server:port project_id=xxx volume_id=yyy instance_id=zzz",
         #"updateqos": "nbs_api_server:port project_id=xxx volume_id=yyy [read_bps=111] [read_iops=222] #[write_bps=333] [write_iops=444]",
         #"extend": "nbs_api_server:port project_id=xxx volume_id=yyy size=yyy"}


def print_usage(p='all'):
    if p == 'all':
        for k,v in helps.items():
            print '%s: %s' % (k, v)
    else:
        print '%s: %s' % (p, helps[p])



def get_kwargs(args):
    kwargs = {}
    kwargs['nbs_api_server'] = args[0]
    for arg in args[1:]:
        arg = arg.replace(' ', '')
        if 'project_id=' in arg:
            kwargs['project_id'] = arg.split('project_id=')[1]
        if 'volume_id=' in arg:
            kwargs['volume_id'] = arg.split('volume_id=')[1]
        if 'instance_id=' in arg:
            kwargs['instance_id'] = arg.split('instance_id=')[1]
        if 'host_ip=' in arg:
            kwargs['host_ip'] = arg.split('host_ip=')[1]
        if 'read_bps=' in arg:
            if arg.split('read_bps=')[1].isdigit():
                kwargs['read_bps'] = arg.split('read_bps=')[1]
            else:
                print "read_bps value is not digit"
                exit()
        if 'read_iops=' in arg:
            if arg.split('read_iops=')[1].isdigit():
                kwargs['read_iops'] = arg.split('read_iops=')[1]
            else:
                print "read_iops value is not digit"
                exit()
        if 'write_bps=' in arg:
            if arg.split('write_bps=')[1].isdigit():
                kwargs['write_bps'] = arg.split('write_bps=')[1]
            else:
                print "write_bps value is not digit"
                exit()
        if 'write_iops=' in arg:
            if arg.split('write_iops=')[1].isdigit():
                kwargs['write_iops'] = arg.split('write_iops=')[1]
            else:
                print "write_iops value is not digit"
                exit()
        if 'size=' in arg:
            if arg.split('size=')[1].isdigit():
                kwargs['size'] = arg.split('size=')[1]
            else:
                print "size value is not digit"
                exit()

    return kwargs


if __name__ == '__main__':
    args = sys.argv[1:]

    if len(args) < 3:
        print_usage()
        exit()

    action = args[0]
    action_method = ACTION_MAP.get(action)
    if not action_method:
        print "no such operation: %s" % action
        exit()

    kwargs = get_kwargs(args[1:])

    print "use default nbs_prefix_url '%s'" % NBS_PREFIX_URL
    action_method(kwargs)

