#! /bin/sh

export LC_ALL=C
export LC_CTYPE="UTF-8",
export LANG="en_US.UTF-8"

echo 'run-kolla.sh: Cleaning directory /home/openstack/.ssh/'
rm -f /home/openstack/.ssh/known_hosts
rm -f /home/openstack/.ssh/id_rsa
rm -f /home/openstack/.ssh/id_rsa.pub

echo 'run-kolla.sh: Running ssh-keygen -t rsa'
ssh-keygen -t rsa

echo 'run-kolla.sh: Running ssh-copy-id kris@controller1'
ssh-copy-id kris@controller1
echo 'run-kolla.sh: Running ssh-copy-id kris@controller2'
ssh-copy-id kris@controller2
echo 'run-kolla.sh: Running ssh-copy-id kris@compute001'
ssh-copy-id kris@compute001

echo 'run-kolla.sh: Running scp controller_setup.sh controller1:/home/kris/controller_setup.sh'
scp controller_setup.sh controller1:/home/kris/controller_setup.sh
echo 'run-kolla.sh: Running scp controller_setup.sh controller2:/home/kris/controller_setup.sh'
scp controller_setup.sh controller2:/home/kris/controller_setup.sh
echo 'run-kolla.sh: Running scp compute_setup.sh compute001:/home/kris/compute_setup.sh'
scp compute_setup.sh compute001:/home/kris/compute_setup.sh

echo 'run-kolla.sh: Running ssh kris@controller1 "sudo bash /home/kris/controller_setup.sh"'
ssh kris@controller1 "sudo bash /home/kris/controller_setup.sh"
echo 'run-kolla.sh: Running ssh kris@controller2 "sudo bash /home/kris/controller_setup.sh"'
ssh kris@controller2 "sudo bash /home/kris/controller_setup.sh"
echo 'run-kolla.sh: Running ssh kris@compute001 “sudo bash /home/kris/compute_setup.sh”'
ssh kris@compute001 “sudo bash /home/kris/compute_setup.sh”


echo 'run-kolla.sh: Running sudo pip install ansible==2.5.2'
sudo pip install ansible==2.5.2

if [ $? -ne 0 ]; then
  echo "Cannot install Ansible"
  exit $?
fi

echo 'run-kolla.sh: Running sudo pip install kolla-ansible==6.0.0'
sudo pip install kolla-ansible==6.0.0

if [ $? -ne 0 ]; then
  echo "Cannot install kolla-ansible"
  exit $?
fi

echo 'run-kolla.sh: Running sudo cp -r /usr/local/share/kolla-ansible/etc_examples/kolla /etc/kolla'
sudo cp -r /usr/local/share/kolla-ansible/etc_examples/kolla /etc/kolla
echo 'run-kolla.sh: Running sudo cp globals.yml /etc/kolla'
cp globals.yml /etc/kolla

export ANSIBLE_HOST_KEY_CHECKING=False

echo 'run-kolla.sh: Running sudo kolla-genpwd'
sudo kolla-genpwd

echo 'run-kolla.sh: Running sudo kolla-ansible -i multinode bootstrap-servers'
sudo kolla-ansible -i multinode bootstrap-servers

if [ $? -ne 0 ]; then
  echo "Bootstrap servers failed"
  exit $?
fi

echo 'run-kolla.sh: Running sudo kolla-ansible -i multinode prechecks'
sudo kolla-ansible -i multinode prechecks

if [ $? -ne 0 ]; then
  echo "Prechecks failed"
  exit $?
fi

echo 'run-kolla.sh: Running sudo kolla-ansible -i multinode deploy'
sudo kolla-ansible -i multinode deploy

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
