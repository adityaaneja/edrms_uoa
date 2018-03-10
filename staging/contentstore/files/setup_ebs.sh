#!/bin/bash
while [ `lsblk -n | grep -c 'xvdx'` -ne 1 ]
do
  echo "Waiting for /dev/xvdx to become available" >>/tmp/test.log
  sleep 10
done

blkid /dev/xvdx |grep 'TYPE="ext4"'
IS_EXT4_VOLUME="$?"
echo $IS_EXT4_VOLUME
if [ $IS_EXT4_VOLUME != 0 ]; then
 		echo "creating filesystem"
		mkfs.ext4 /dev/xvdx
fi
echo "Mounting..."
mount /dev/xvdx /mnt
echo '/dev/xvdx /mnt ext4 defaults 0 0' | tee -a /etc/fstab

###############
Setup NFS server
###############

yum install nfs-utils -y
chmod -R 755 /mnt
chown nfsnobody:nfsnobody /mnt
systemctl enable rpcbind
systemctl enable nfs-server
systemctl enable nfs-lock
systemctl enable nfs-idmap
systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap

mkdir /mnt/contentstore; chown nfsnobody.nfsnobody /mnt/contentstore
mkdir /mnt/contentstore.deleted; chown nfsnobody.nfsnobody /mnt/contentstore.deleted

cat <<EOF > /etc/exports
/mnt    10.0.1.0/24(rw,sync,no_root_squash,no_all_squash)
EOF

systemctl restart nfs-server
