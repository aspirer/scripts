#! /bin/bash
python get-ss-cfg.py
sudo pkill sslocal
sslocal -c ss-1.cfg &
