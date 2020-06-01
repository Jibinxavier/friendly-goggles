#!/usr/bin/env bash
 
if [[ $UID > 0 ]]; then
    echo "Please run as root"
    exit
fi 
chown root:root consul
mv consul /usr/local/bin/

consul --version
useradd --system --home /etc/consul.d --shell /bin/false consul


mkdir --parents /opt/consul

chown --recursive consul:consul /opt/consul

touch /etc/systemd/system/consul.service



cat << EOF > /etc/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/consul.hcl

[Service]
Type=notify
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d/
ExecReload=/usr/local/bin/consul reload
ExecStop=/usr/local/bin/consul leave
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

mkdir --parents /etc/consul.d

touch /etc/consul.d/consul.hcl
chown --recursive consul:consul /etc/consul.d
 
cat << EOF >  /etc/consul.d/consul.hcl
datacenter = "Vagrant",
data_dir = "/opt/consul"
encrypt = "Luj2FZWwlt8475wD1WtwUQ=="
server= true
bootstrap_expect =1
bind_addr = "192.168.33.72"  
performance {
    raft_multiplier = 1
}

EOF


chmod 640 /etc/consul.d/consul.hcl

systemctl enable consul
systemctl start consul
systemctl status consul