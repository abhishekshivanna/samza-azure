# Samza on Azure

## Setup a YARN cluster on Azure

This guide is to setup a YARN cluster with 1 RM (no HA) and multiple NM hosts.

1) Login to your account on http://portal.azure.com/
2) Start cloudshell (If needed, setup a new Storage Account and File Share)

```sh
git clone https://github.com/abhishekshivanna/azure-hacks.git
cd azure-hacks/samza-terraform
terrform init
```

Create a file called `variables.tfvars` and add the following contents
```properties
prefix = "<some-prefix-to-name-resources>"
resource_group_name = "<existing-resource-group-name>"
subscription_id = "<subscritpion-id>"
username = "<admin-username>"
password = "<admin-password>"
network_security_group_name = "<existing-network-sec-group-name>"
location = "westus2"
```
Take a look at the `main.tf` file under the `samza-terraform` directory. Keep only the "modules" that you want deployed as part of this run.

eg: if you don't want to deploy a Kafka cluster comment the module sections for `zookeeper` and `kafka` in `main.tf`

### Deploy

```sh
terraform plan -var-file=variables.tfvars
```
Make sure that plan looks correct - its creating the appropriate resources. If you think the resources being created looks correct - run the following command

```sh
terraform deploy -var-file=variables.tfvars
```

### Undeploy/Cleanup resources
```sh
terraform plan -destroy -var-file=variables.tfvars
```
Make sure everything being destoryed belongs to your deployment above. Then run the following command
```sh
terraform destroy -var-file=variables.tfvars
```
