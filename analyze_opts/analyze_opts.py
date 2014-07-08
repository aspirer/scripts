#!/usr/bin/env python
# vim: tabstop=4 shiftwidth=4 softtabstop=4

# Copyright (c) 2012, Cloudscaling
# Copyright (c) 2013, Netease Corp.
# All Rights Reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
'''
find_unused_options.py

Compare the nova.conf file with the nova.conf.sample file to find any unused
options or default values in nova.conf
'''
import argparse
import os
import re
import sys

sys.path.append(os.getcwd())
from oslo.config import iniparser


class PropertyCollecter(iniparser.BaseParser):
    def __init__(self):
        super(PropertyCollecter, self).__init__()
        self.key_value_pairs = {}

    def assignment(self, key, value):
        self.key_value_pairs[key] = value

    def new_section(self, section):
        pass

    @classmethod
    def collect_properties(cls, lineiter, sample_format=False):
        def clean_sample(f):
            for line in f:
                if line.startswith("#") and not line.startswith("# "):
                    line = line[1:]
                yield line
        pc = cls()
        if sample_format:
            lineiter = clean_sample(lineiter)
        pc.parse(lineiter)
        return pc.key_value_pairs


def _str_to_bool(s):
    return s in ('t', 'T', 'true', 'True', '1')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='''Compare the nova.conf
    file with the nova.conf.sample file to find any unused options or
    default values in nova.conf''')

    parser.add_argument('-c', action='store',
                        default='/etc/nova/nova.conf',
                        help='path to nova.conf\
                        (defaults to /etc/nova/nova.conf)')
    parser.add_argument('-s', default='./etc/nova/nova.conf.sample',
                        help='path to nova.conf.sample\
                        (defaults to ./etc/nova/nova.conf.sample')
    parser.add_argument('-v', default=False,
                        help='report all differences(defaults to False)')

    options = parser.parse_args()

    conf_file_options = PropertyCollecter.collect_properties(open(options.c))
    sample_conf_file_options = PropertyCollecter.collect_properties(
        open(options.s), sample_format=True)
    verbose = _str_to_bool(options.v)

    print '-----------------------------------'
    print 'Configs in template "%s" -NOT- in "%s".' % (options.s, options.c)
    print 'WARNING: These configs may be missed!'
    print '-----------------------------------'
    count = 0
    for k, v in sorted(sample_conf_file_options.items()):
        if k not in conf_file_options:
            # Missing keys
            print "- %s = %s" % (k, v[0])
            count += 1

    print ''
    print '-----------------------------------'
    print 'Configs -NOT- in template "%s" in "%s".' % (options.s, options.c)
    print 'NOTE: These configs may be needless.'
    print '-----------------------------------'
    for k, v in sorted(conf_file_options.items()):
        if k not in sample_conf_file_options:
            # New added keys
            print "+ %s = %s " % (k, v[0])

    print ''
    print '-----------------------------------'
    print 'Different configs of "%s" and "%s".' % (options.s, options.c)
    print 'NOTE: These configs may be wrong.'
    print '-----------------------------------'
    for k, v in sorted(sample_conf_file_options.items()):
        if k in conf_file_options and v != conf_file_options[k]:
            vs = v[0]
            vc = conf_file_options[k][0]
            vsl = vs.lower()
            vcl = vc.lower()
            ip_rule = r'\d+.\d+.\d+.\d+'
            # Skip unimportant differences
            if not verbose:
                # Handle lower/upper case of true/false
                if vsl == vcl and vsl in ('true', 'false'):
                    continue
                # Handle only different ip value
                elif re.split(ip_rule, vs) == re.split(ip_rule, vc):
                    continue

            # Different value
            print '- %s = %s' % (k, vs)
            print '+ %s = %s' % (k, vc)
