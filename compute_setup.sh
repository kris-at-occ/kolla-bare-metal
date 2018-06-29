#! /bin/sh

DEBIAN_FRONTEND=noninteractive apt update
DEBIAN_FRONTEND=noninteractive apt install -y python python-simplejson
DEBIAN_FRONTEND=noninteractive apt install -y qemu-kvm

echo "configfs" >> /etc/modules
update-initramfs -u
systemctl daemon-reload

systemctl stop open-iscsi
systemctl disable open-iscsi
systemctl stop iscsid
systemctl disable iscsid

reboot
