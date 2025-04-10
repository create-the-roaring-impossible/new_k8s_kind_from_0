FROM alpine:3.21.3

RUN apk update \
    && apk upgrade \
    # Install dependencies
    && apk add --no-cache \
       bash \
       git \
    # Install Terraform
    && apk add --update --virtual .deps --no-cache gnupg \
    && cd /tmp \
    && wget https://releases.hashicorp.com/terraform/1.11.4/terraform_1.11.4_linux_amd64.zip \
    && wget https://releases.hashicorp.com/terraform/1.11.4/terraform_1.11.4_SHA256SUMS \
    && wget https://releases.hashicorp.com/terraform/1.11.4/terraform_1.11.4_SHA256SUMS.sig \
    && wget -qO- https://www.hashicorp.com/.well-known/pgp-key.txt | gpg --import \
    && gpg --verify terraform_1.11.4_SHA256SUMS.sig terraform_1.11.4_SHA256SUMS \
    && grep terraform_1.11.4_linux_amd64.zip terraform_1.11.4_SHA256SUMS | sha256sum -c \
    && unzip /tmp/terraform_1.11.4_linux_amd64.zip -d /tmp \
    && mv /tmp/terraform /usr/local/bin/terraform \
    && rm -f /tmp/terraform_1.11.4_linux_amd64.zip terraform_1.11.4_SHA256SUMS 1.11.4/terraform_1.11.4_SHA256SUMS.sig \
    && apk del .deps

USER tfsvcusr