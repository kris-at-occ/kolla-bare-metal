#! /bin/sh

export LC_ALL=C
export LC_CTYPE="UTF-8",
export LANG="en_US.UTF-8"

export ANSIBLE_HOST_KEY_CHECKING=False

echo 'run-kolla.sh: Running sudo kolla-genpwd'
sudo kolla-genpwd

echo 'run-kolla.sh: Running kolla-ansible -i multinode bootstrap-servers'
kolla-ansible -i multinode bootstrap-servers

if [ $? -ne 0 ]; then
  echo "Bootstrap servers failed"
  exit $?
fi

echo 'run-kolla.sh: Running kolla-ansible -i multinode prechecks'
kolla-ansible -i multinode prechecks

if [ $? -ne 0 ]; then
  echo "Prechecks failed"
  exit $?
fi

echo 'run-kolla.sh: Running kolla-ansible -i multinode deploy'
kolla-ansible -i multinode deploy

if [ $? -ne 0 ]; then
  echo "Deploy failed"
  exit $?
fi

echo 'run-kolla.sh: Running sudo kolla-ansible -i multinode post-deploy'
sudo kolla-ansible post-deploy

echo 'run-kolla.sh: Running sudo pip install python-openstackclient'
sudo pip install python-openstackclient

echo 'run-kolla.sh: Running sudo cp init-runonce /usr/local/share/kolla-ansible/init-runonce'
sudo cp init-runonce /usr/local/share/kolla-ansible/init-runonce
echo 'run-kolla.sh: Running . /etc/kolla/admin-openrc.sh'
. /etc/kolla/admin-openrc.sh
echo 'run-kolla.sh: Running cd /usr/local/share/kolla-ansible'
cd /usr/local/share/kolla-ansible
echo 'run-kolla.sh: Running ./init-runonce'
./init-runonce
echo "Horizon available at 10.0.0.10, user 'admin', password below:"
grep keystone_admin_password /etc/kolla/passwords.yml
