# TF State Configuraiton for AWS


To decrypt / encrypt `terraform.tfstate`:

 - rage -eai tfstate.key -o terraform.tfstate.rage terraform.tfstate
 - rage -di tfstate.key -o terraform.tfstate terraform.tfstate.rage

The `tfstate.key` is in the Shared vault.

Or, copy the `tfstate.key` to `.rage.key` and run the following
to automatically manage the encryption and decryption:

```bash
git config filter.rage.clean 'rage -eai .rage.key'
git config filter.rage.smudge 'rage -di .rage.key'
git config filter.rage.required true
```

