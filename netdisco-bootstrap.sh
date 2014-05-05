#!/bin/bash

curl -L http://cpanmin.us/ | perl - --notest --verbose --local-lib ~/perl5 App::Netdisco

mkdir ~/bin
ln -s ~/perl5/bin/{localenv,netdisco-*} ~/bin/

mkdir ~/environments
cp ~/perl5/lib/perl5/auto/share/dist/App-Netdisco/environments/deployment.yml ~/environments
chmod +w ~/environments/deployment.yml

sed -i "s/user: .*/user: 'netdisco'/;s/pass: .*/pass: '$(cat /dev/shm/password)'/" ~/environments/deployment.yml

rm /dev/shm/password

#echo 'no_auth: true' >> environments/deployment.yml

yes y | ~/bin/netdisco-deploy

~/bin/netdisco-web start --host=127.0.0.1
~/bin/netdisco-daemon start

