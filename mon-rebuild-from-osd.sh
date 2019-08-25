#!/bin/sh -xe

# modified script from ceph documentation at:
# https://docs.ceph.com/docs/jewel/rados/troubleshooting/troubleshooting-mon/#recovery-using-osds
#
# additional complexity is there to support mons which run on same
# nodes as osds

# this works only with short hostnames (hostname -s)
hosts="ceph01 ceph02 ceph03 ceph04 ceph05"

ms=/tmp/mon-store
mkdir $ms
# collect the cluster map from OSDs
for host in $hosts; do
	LOCAL_HOST=1
	if [ `hostname -s` != $host ] ; then
		rsync -avz --delete $ms/ root@$host:$ms/
		rm -rf $ms
		LOCAL_HOST=0
	fi

	ssh root@$host <<EOF
echo "HOST: $host"
for osd in /var/lib/ceph/osd/ceph-*; do
	echo "OSD: \$osd"
	ceph-objectstore-tool --data-path \$osd --op update-mon-db --mon-store-path $ms
done
EOF

	test $LOCAL_HOST -eq 0 && rsync -avz root@$host:$ms/ $ms/
done


# rebuild the monitor store from the collected map, if the cluster does not
# use cephx authentication, we can skip the following steps to update the
# keyring with the caps, and there is no need to pass the "--keyring" option.
# i.e. just use "ceph-monstore-tool /tmp/mon-store rebuild" instead
#ceph-authtool /etc/ceph/ceph.client.admin.keyring -n mon. --cap mon 'allow *'
ceph-authtool /etc/ceph/ceph.client.admin.keyring -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *'
ceph-monstore-tool /tmp/mon-store rebuild -- --keyring /etc/ceph/ceph.client.admin.keyring
# backup corrupted store.db just in case
mv /var/lib/ceph/mon/ceph-ceph01/store.db /var/lib/ceph/mon/ceph-ceph01/store.db.`date +%Y%m%d-%H%M%S`
mv /tmp/mon-store/store.db /var/lib/ceph/mon/ceph-ceph01/store.db
chown -R ceph:ceph /var/lib/ceph/mon/ceph-ceph01/store.db

