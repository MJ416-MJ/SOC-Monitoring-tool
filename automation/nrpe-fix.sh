#!/bin/bash
set -e
sed -i 's/^command.check_load.=/#&/' /etc/nagios/nrpe.cfg
sed -i 's|^allowed_hosts=.*|allowed_hosts=127.0.0.1,10.10.10.11|' /etc/nagios/nrpe.cfg
grep -q '^include_dir=/etc/nagios/nrpe.d' /etc/nagios/nrpe.cfg || echo 'include_dir=/etc/nagios/nrpe.d/' >> /etc/nagios/nrpe.cfg
mkdir -p /etc/nagios/nrpe.d
cat > /etc/nagios/nrpe.d/soc.cfg <<'EOF'
command[check_disk]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /
command[check_load]=/usr/lib/nagios/plugins/check_load -w 5,4,3 -c 10,8,6
EOF
systemctl restart nagios-nrpe-server
systemctl is-active nagios-nrpe-server
/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /
/usr/lib/nagios/plugins/check_load -w 5,4,3 -c 10,8,6
