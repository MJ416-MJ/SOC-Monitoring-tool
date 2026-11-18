#!/bin/bash
# usage: sudo ./target-setup.sh tgt-01
set -e
NAME=$1
apt-get update
apt-get install -y prometheus-node-exporter zabbix-agent2 nagios-nrpe-server monitoring-plugins-basic snmpd openssh-server
id ansible &>/dev/null || adduser --disabled-password --gecos '' ansible

Z=/etc/zabbix/zabbix_agent2.conf
sed -i 's|^Server=.*|Server=10.10.10.11,172.16.0.0/12|' $Z
sed -i 's|^ServerActive=.*|ServerActive=10.10.10.11|' $Z
sed -i "s|^Hostname=.*|Hostname=$NAME|" $Z
grep -q '^HostMetadata=' $Z || echo 'HostMetadata=linux' >> $Z

sed -i 's|^allowed_hosts=.*|allowed_hosts=127.0.0.1,10.10.10.11|' /etc/nagios/nrpe.cfg

cat > /usr/local/bin/disk_cleanup.sh <<'EOF'
#!/bin/bash
journalctl --vacuum-size=200M
find /var/log -name '*.gz' -mtime +7 -delete
rm -f /var/fill.img
EOF
chmod 755 /usr/local/bin/disk_cleanup.sh

echo 'ansible ALL=(root) NOPASSWD: /usr/local/bin/disk_cleanup.sh' > /etc/sudoers.d/ansible
chmod 440 /etc/sudoers.d/ansible
visudo -cf /etc/sudoers.d/ansible

systemctl enable --now prometheus-node-exporter zabbix-agent2 nagios-nrpe-server snmpd
systemctl restart zabbix-agent2 nagios-nrpe-server
