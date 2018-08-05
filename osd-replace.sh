ID=2
DEVICE=/dev/sda4

ceph osd set noout

ceph osd out $ID

systemctl kill ceph-osd@$ID

# wait for umount
while ! umount /var/lib/ceph/osd/ceph-$ID ; do sleep 1 ; done

ceph-volume lvm zap $DEVICE

ceph osd destroy $ID --yes-i-really-mean-it

ceph-volume lvm create --bluestore --data $DEVICE --osd-id $ID

ceph daemon osd.$ID config set osd_max_backfills 64

#ceph osd unset noout
