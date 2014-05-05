#!/bin/bash

# loosely following http://search.cpan.org/~oliver/App-Netdisco-2.019003/lib/App/Netdisco.pm

apt-get update
apt-get install -y postgresql curl libsnmp-perl make libdbd-pg-perl nginx

# It's random and long, right? :-/
PASSWORD="$(uuidgen)"

su - postgres -c 'createuser netdisco -D -R -S'
su - postgres -c 'createdb netdisco -O netdisco'
su - postgres -c "psql -c \"alter user netdisco with password '$PASSWORD'\""

useradd -m -s /bin/bash -p netdisco

echo "$PASSWORD" > /dev/shm/password

su - netdisco -c /vagrant/netdisco-bootstrap.sh

rm /dev/shm/password

cat <<EOF >/etc/nginx/sites-enabled/netdisco
server {
	listen 80;
	location / {
		proxy_pass        http://localhost:5000;
		proxy_pass_header Server;
	}
}
EOF

/etc/init.d/nginx restart

crontab -u netdisco /vagrant/netdisco.crontab
