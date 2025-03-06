## Testing on an AWS Graviton instance

### Infra

Name: aws-graviton
domain: gravitron.pem ec2-user@ec2-54-209-135-27.compute-1.amazonaws.com
aws account: Ecosystem Tests (275927176912)
region: us-east-1

AWS Linux AMI 64-bit ARM
t4g.small
30GB of disk

Note: using an A1 Instance Type (a1.medium) results in a kernel panic.

Note that the security group in AWS needs to allow ssh access (port 22) from any IP to allow github actions to easily access it.
Allowlisting all github action IPs would be quite cumbersome.

### One time setup

### GitHub Actions

Set up the `SSH_KEY_GRAVITON` env var: Copy & paste the `.pem` private ssh key file contents without any modification into GitHub's UI.

### Remote machine maintenance

1. Get the SSH key from 1Password. Search for `ORM Infra - AWS Gravitron Ecosystem Tests SSH Key`.
2. SSH into the machine `ssh -i gravitron.pem ec2-user@ec2-54-209-135-27.compute-1.amazonaws.com`
3. Update node via nvm (is already installed). E.g. `nvm install 22 && nvm alias default 22`

Optionally: Update/install NVM: `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash`
