# TF State Configuraiton for AWS


To decrypt / encrypt `terraform.tfstate`:

 - rage -eai tfstate.key -o terraform.tfstate.rage terraform.tfstate
 - rage -di tfstate.key -o terraform.tfstate terraform.tfstate.rage

The `tfstate.key` is in the Shared vault.

