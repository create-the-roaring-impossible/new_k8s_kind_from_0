FROM alpine:3.22

RUN apk update \
    && apk upgrade \
    # Install dependencies
    && apk add --no-cache \
       bash \
       ca-certificates \
       curl \
       git \
       icu-libs \
       krb5-libs \
       less \
       libgcc \
       libintl \
       libssl3 \
       libstdc++ \
       ncurses-terminfo-base \
       sudo \
       tzdata \
       userspace-rcu \
       zlib \
    # Install PowerShell
    && apk -X https://dl-cdn.alpinelinux.org/alpine/edge/main add --no-cache \
       lttng-ust \
       openssh-client \
    && curl -L https://github.com/PowerShell/PowerShell/releases/download/v7.5.3/powershell-7.5.3-linux-musl-x64.tar.gz -o /tmp/powershell.tar.gz \
    && sudo mkdir -p /opt/microsoft/powershell/7 \
    && sudo tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7 \
    && sudo chmod +x /opt/microsoft/powershell/7/pwsh \
    && sudo ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh \
    # Install AWS CLI
    # TODO: to install AWS CLI
    # Install Azure CLI
    # TODO: to install Azure CLI
    # Install Terraform
    && apk --no-cache add --update --virtual .deps --no-cache gnupg \
    && cd /tmp \
    && curl --proto "=https" --tlsv1.2 -sSf -LO https://releases.hashicorp.com/terraform/1.13.1/terraform_1.13.1_linux_amd64.zip \
    && curl --proto "=https" --tlsv1.2 -sSf -LO https://releases.hashicorp.com/terraform/1.13.1/terraform_1.13.1_SHA256SUMS \
    && curl --proto "=https" --tlsv1.2 -sSf -LO https://releases.hashicorp.com/terraform/1.13.1/terraform_1.13.1_SHA256SUMS.sig \
    && curl --proto "=https" --tlsv1.2 -sSf https://www.hashicorp.com/.well-known/pgp-key.txt | gpg --import \
    && gpg --verify terraform_1.13.1_SHA256SUMS.sig terraform_1.13.1_SHA256SUMS \
    && grep terraform_1.13.1_linux_amd64.zip terraform_1.13.1_SHA256SUMS | sha256sum -c \
    && unzip /tmp/terraform_1.13.1_linux_amd64.zip -d /tmp \
    && mv /tmp/terraform /usr/local/bin/terraform \
    && rm -f /tmp/terraform_1.13.1_linux_amd64.zip terraform_1.13.1_SHA256SUMS terraform_1.13.1_SHA256SUMS.sig \
    # Install tfsec
    && wget -qO /usr/local/bin/tfsec https://github.com/aquasecurity/tfsec/releases/download/v1.28.13/tfsec-linux-amd64 \
    && chmod +x /usr/local/bin/tfsec \
    && apk del .deps \
    && apk cache clean \
    # Add user "tfsvc_usr" and give sudo permissions
    && addgroup tfsvc_grp \
    && adduser -D -G tfsvc_grp tfsvc_usr \
    && mkdir -p /etc/sudoers.d \
    && echo "tfsvc_usr ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/tfsvc_usr

USER tfsvc_usr