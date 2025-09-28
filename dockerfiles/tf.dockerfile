FROM alpine:3.22

RUN apk update \
    && apk upgrade \
    # Install dependencies
    && apk add --no-cache \
       bash \
       git \
    # Install Terraform
    && apk --no-cache add --update --virtual .deps --no-cache gnupg \
    && cd /tmp \
    && wget --secure-protocol=TLSv1_2 --max-redirect=0 https://releases.hashicorp.com/terraform/1.13.1/terraform_1.13.1_linux_amd64.zip \
    && wget --secure-protocol=TLSv1_2 --max-redirect=0 https://releases.hashicorp.com/terraform/1.13.1/terraform_1.13.1_SHA256SUMS \
    && wget --secure-protocol=TLSv1_2 --max-redirect=0 https://releases.hashicorp.com/terraform/1.13.1/terraform_1.13.1_SHA256SUMS.sig \
    && wget --secure-protocol=TLSv1_2 --max-redirect=0 -qO- https://www.hashicorp.com/.well-known/pgp-key.txt | gpg --import \
    && gpg --verify terraform_1.13.1_SHA256SUMS.sig terraform_1.13.1_SHA256SUMS \
    && grep terraform_1.13.1_linux_amd64.zip terraform_1.13.1_SHA256SUMS | sha256sum -c \
    && unzip /tmp/terraform_1.13.1_linux_amd64.zip -d /tmp \
    && mv /tmp/terraform /usr/local/bin/terraform \
    && rm -f /tmp/terraform_1.13.1_linux_amd64.zip terraform_1.13.1_SHA256SUMS terraform_1.13.1_SHA256SUMS.sig \
    # Install tfsec
    && wget --secure-protocol=TLSv1_2 --max-redirect=0 -qO /usr/local/bin/tfsec https://github.com/aquasecurity/tfsec/releases/download/v1.28.13/tfsec-linux-amd64 \
    && chmod +x /usr/local/bin/tfsec \
    && apk del .deps \
    && apk cache clean \
    # Add user "tfsvc_usr" and give sudo permissions
    && addgroup tfsvc_grp \
    && adduser -D -G tfsvc_grp tfsvc_usr \
    && mkdir -p /etc/sudoers.d \
    && echo "tfsvc_usr ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/tfsvc_usr

USER tfsvc_usr