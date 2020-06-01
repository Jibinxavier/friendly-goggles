### Search Vault logs using Elasticsearch (Work In Progress)
To test Hashicorp Vault and Elasticsearch setup. In this setup, [Fluentd](https://docs.fluentd.org/) is used to forward the logs to Elasticsearch. In the current setup Elasticsearch and Kibana are run locally.

#### Requirements
- Vagrant + Virtualbox
- [Vault](https://www.vaultproject.io/downloads)
- [Consul](https://www.consul.io/downloads)
- Elasticsearch 

#### Setup
- A VM each for Vault and Consul
- Logs are forwarded to Elasticsearch on 10.0.2.2 ([Gateway](https://stackoverflow.com/questions/19933550/how-to-connect-with-host-postgresql-from-vagrant-virtualbox-machine))