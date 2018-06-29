#! /bin/sh

export LC_ALL=C
export LC_CTYPE="UTF-8",
export LANG="en_US.UTF-8"

apt install -y python-jinja2 python-pip libssl-dev curl git vim
pip install -U pip

reboot
