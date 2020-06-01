


if [[ $UID > 0 ]]; then
    echo "Please run as root"
    exit
fi 

chown root:root vault

mv vault /usr/local/bin/
setcap cap_ipc_lock=+ep /usr/local/bin/vault


useradd --system --home /etc/vault.d --shell /bin/false vault


cat << EOF > /etc/systemd/system/vault.service


[Unit]
Description="HashiCorp Vault - A tool for managing secrets"
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault.d/vault.hcl
StartLimitIntervalSec=60
StartLimitBurst=3

[Service]
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
StartLimitInterval=60
StartLimitIntervalSec=60
StartLimitBurst=3
LimitNOFILE=65536
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target

EOF


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
retry_join = ["192.168.33.72"]
bind_addr = "192.168.33.71"
EOF 


chmod 640 /etc/consul.d/consul.hcl
 
 
systemctl enable consul
systemctl start consul
systemctl status consul








mkdir --parents /etc/vault.d
touch /etc/vault.d/vault.hcl
chown --recursive vault:vault /etc/vault.d
chmod 640 /etc/vault.d/vault.hcl


cat << EOF > /etc/vault.d/vault.hcl
storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault"
}

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = 1
}
EOF
echo "heree"
systemctl enable vault
systemctl start vault
systemctl status vault