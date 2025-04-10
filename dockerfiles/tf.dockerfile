FROM alpine:3.21.3

RUN apk update \
    && apk upgrade \
    # Install dependencies
    && apk add --no-cache \
       bash \
       git \
    # Install Terraform
    && wget https://releases.hashicorp.com/terraform/$(wget -qO- https://releases.hashicorp.com/terraform/ | grep -oP 'terraform/\K[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)/terraform_$(wget -qO- https://releases.hashicorp.com/terraform/ | grep -oP 'terraform/\K[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)_linux_amd64.zip \
    && unzip terraform_*_linux_amd64.zip -d /usr/local/bin/ \
    && rm terraform_*_linux_amd64.zip \
    && terraform --version

USER tfsvcusr