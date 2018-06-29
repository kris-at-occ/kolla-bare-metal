#! /bin/sh

LC_ALL=C
LC_CTYPE="UTF-8",
LANG="en_US.UTF-8"

pip install ansible==2.5.2

if [ $? -ne 0 ]; then
  echo "Cannot install Ansible"
  exit $?
fi

pip install kolla-ansible==6.0.0

if [ $? -ne 0 ]; then
  echo "Cannot install kolla-ansible"
  exit $?
fi

cp -r /usr/local/share/kolla-ansible/etc_examples/kolla /etc/kolla
cp globals.yml /etc/kolla

export ANSIBLE_HOST_KEY_CHECKING=False

kolla-genpwd
kolla-ansible -i multinode bootstrap-servers

if [ $? -ne 0 ]; then
  echo "Bootstrap servers failed"
  exit $?
fi

kolla-ansible -i multinode prechecks

if [ $? -ne 0 ]; then
  echo "Prechecks failed"
  exit $?
fi

kolla-ansible -i multinode deploy

if [ $? -ne 0 ]; then
  echo "Deploy failed"
  exit $?
fi

kolla-ansible post-deploy
pip install python-openstackclient
cp init-runonce /usr/local/share/kolla-ansible/init-runonce
. /etc/kolla/admin-openrc.sh
cd /usr/local/share/kolla-ansible
./init-runonce
echo "Horizon available at 10.0.0.10, user 'admin', password below:"
grep keystone_admin_password /etc/kolla/passwords.yml
