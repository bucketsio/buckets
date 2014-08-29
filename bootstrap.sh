#!/bin/bash
echo -e "==> LINKING: /vagrant > ~/buckets"
rm -rf /home/vagrant/buckets
ln -s /vagrant /home/vagrant/buckets
cd /home/vagrant/buckets

echo -e "==> RUNNING: npm install -g grunt-cli bower"
npm install -g grunt-cli bower

echo -e "==> RUNNING: npm install"
sudo -u vagrant -H bash -c 'npm install'

echo -e "==> RUNNING: grunt serve"
sudo -u vagrant -H bash -c 'grunt serve'
