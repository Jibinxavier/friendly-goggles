
if [[ $UID > 0 ]]; then
    echo "Please run as root"
    exit
fi 

# Install fluentd https://docs.fluentd.org/installation/install-by-rpm
curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent3.sh | sh

systemctl start td-agent.service

# Test message 
curl -X POST -d 'json={"json":"message"}' http://localhost:8888/debug.test
# Should be logged 
tail /var/log/td-agent/td-agent.log


# Adding source and forwarding rule
cat << EOF > /etc/td-agent/td-agent.conf
<source>
  @type syslog
  port 5140
  bind 0.0.0.0
  tag system
</source>



<match system.*>
  @type elasticsearch
  host 10.0.2.2
  port 9200
  index_name fluentd.${tag}.%Y%m%d
</match>

EOF

# Add the fluentd forwarding rule
sed -i 's/#*.* @@remote-host:514/*.* @127.0.0.1:5140/' /etc/rsyslog.conf

service rsyslog restart 
service td-agent restart