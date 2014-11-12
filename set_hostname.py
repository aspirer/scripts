#! /usr/bin/python
# author: hzwangpan@corp.netease.com

import httplib
import os
import time


HTTPTIMEOUT = 3
MAX_RETRY_TIMES = 3
WAIT_INTERNAL = 1
INSTANCE_TAG_DIR = "/var/lib/cloud/nvs/"
TAG_FILE_NAME = "instance-id"
INSTANCE_ID_URI = "/2009-04-04/meta-data/instance-id"
HOST_NAME_URI = "/2009-04-04/meta-data/local-hostname"


def send_request(uri):
    url = '169.254.169.254'
    method = 'GET'
    headers = {'Content-type': 'application/json',
               'Accept': 'application/json'}

    for i in range(0, MAX_RETRY_TIMES):
        try:
            conn = httplib.HTTPConnection(url, timeout=HTTPTIMEOUT)
            conn.request(method, uri, '', headers)
            response = conn.getresponse()
            data = response.read()
            conn.close()
            status = response.status
            if status in (200, 202):
                return data
            else:
                if i + 1 == MAX_RETRY_TIMES:
                    msg = ('Unexpected status %(status)s while %(method)s '
                           '%(uri)s' % locals())
                    raise Exception(msg)
                else:
                    time.sleep(WAIT_INTERNAL)
                    continue
        except Exception as e:
            print 'Exception occurs while %(method)s %(url)s%(uri)s' % locals()
            if i + 1 == MAX_RETRY_TIMES:
                raise e
            else:
                time.sleep(WAIT_INTERNAL)


def get_host_name():
    local_hostname = send_request(HOST_NAME_URI)
    host_name = local_hostname.split('.novalocal')[0]
    if host_name:
        return host_name
    else:
        raise Exception()


def get_instance_id():
    return send_request(INSTANCE_ID_URI)


def make_instance_tag(instance_id):
    if not os.path.exists(INSTANCE_TAG_DIR):
        os.makedirs(INSTANCE_TAG_DIR)

    tag_file = os.path.join(INSTANCE_TAG_DIR, TAG_FILE_NAME)
    with open(tag_file, 'w') as f:
        f.write(instance_id)


def is_new_instance(instance_id):
    if not os.path.exists(INSTANCE_TAG_DIR):
        return True

    tag_file = os.path.join(INSTANCE_TAG_DIR, TAG_FILE_NAME)
    if not os.path.exists(tag_file):
        return True

    tag_id = None
    with open(tag_file) as f:
        tag_id = f.read()

    if tag_id != instance_id:
        return True
    else:
        return False


def change_host_name(host_name):
    # change /etc/hostname
    with open('/etc/hostname', 'w') as f:
        f.writelines([host_name, '\n'])
    # enable new host name immediately
    os.system("hostname %s" % host_name)

    # add new host name to /etc/hosts
    with open('/etc/hosts', 'a') as f:
        f.writelines(['\n', '127.0.0.1\t', host_name, '\n'])

    print '*' * 50
    print 'Host name is changed to: %s' % host_name
    print '*' * 50


if __name__ == '__main__':
    print 'Going to change the host name...'
    # check this is a new instance or not
    instance_id = get_instance_id()
    if is_new_instance(instance_id):
        host_name = get_host_name()
        change_host_name(host_name)
        make_instance_tag(instance_id)
        # gen new ssh host key
        os.system('rm -f /etc/ssh/ssh_host_*')
        os.system('ssh-keygen -t dsa -N "" -f /etc/ssh/ssh_host_dsa_key')
        os.system('ssh-keygen -t rsa -N "" -f /etc/ssh/ssh_host_rsa_key')
        os.system('ssh-keygen -t ecdsa -N "" -f /etc/ssh/ssh_host_ecdsa_key')
    else:
        print 'Host name has already been changed, exit now.'
