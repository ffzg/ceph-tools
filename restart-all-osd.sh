#!/bin/sh -xe

ssh ceph01 systemctl restart ceph-osd@0
ssh ceph01 systemctl restart ceph-osd@1

ssh ceph02 systemctl restart ceph-osd@2
ssh ceph02 systemctl restart ceph-osd@3

ssh ceph03 systemctl restart ceph-osd@4
ssh ceph03 systemctl restart ceph-osd@5

ssh ceph04 systemctl restart ceph-osd@6
ssh ceph04 systemctl restart ceph-osd@7

ssh ceph05 systemctl restart ceph-osd@8 # fails
ssh ceph05 systemctl restart ceph-osd@9
