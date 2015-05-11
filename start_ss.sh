#! /bin/bash
python get-ss-cfg.py
sudo pkill sslocal
sslocal --fast-open -c ss-1.cfg -vv &
