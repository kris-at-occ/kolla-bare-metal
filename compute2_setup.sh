#! /bin/sh

apt install -y python python-simplejson glances
apt install -y qemu-kvm

echo "configfs" >> /etc/modules
update-initramfs -u
systemctl daemon-reload

systemctl stop open-iscsi
systemctl disable open-iscsi
systemctl stop iscsid
systemctl disable iscsid

reboot
