#!/bin/sh -xe

ssh ceph01 systemctl restart ceph-mon@ceph01
ssh ceph02 systemctl restart ceph-mon@ceph02
ssh ceph03 systemctl restart ceph-mon@ceph03
