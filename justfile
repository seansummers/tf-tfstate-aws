env := 'sbx'

#region := env_var_or_default('AWS_REGION',shell('aws configure get region'))

region := env_var_or_default('AWS_REGION', 'us-east-1')

# export TF_ACCOUNT_NUMBER := `aws sts get-caller-identity --query Account --output text`

plan region=region env=env:
    tofu -chdir=resources plan -out ../{{ region }}_{{ env }}.tfplan -var-file ../environments/{{ region }}/{{ env }}/inputs.tfvars

apply region=region env=env:
    tofu -chdir=resources apply ../{{ region }}_{{ env }}.tfplan

destroy region=region env=env:
    tofu -chdir=resources destroy

show region=region env=env:
    tofu -chdir=resources show

init region=region env=env:
    cd resources && tofu init -backend-config ../environments/{{ region }}/{{ env }}/backend.hcl -reconfigure
