FROM alpine:3.22

RUN apk update \
    && apk upgrade \
    # Install dependencies
    && apk add --no-cache \
       bash \
       ca-certificates \
       cargo \
       curl \
       gcc \
       git \
       icu-libs \
       krb5-libs \
       less \
       libffi-dev \
       libgcc \
       libintl \
       libssl3 \
       libstdc++ \
       lttng-ust \
       make \
       musl-dev \
       ncurses-terminfo-base \
       openssh-client \
       openssl-dev \
       py3-pip \
       python3 \
       python3-dev \
       sudo \
       tzdata \
       userspace-rcu \
       zlib \
    # Install PowerShell
    && curl --proto "=https" --tlsv1.2 -sSf -L https://github.com/PowerShell/PowerShell/releases/download/v7.5.3/powershell-7.5.3-linux-musl-x64.tar.gz -o /tmp/powershell.tar.gz \
    && sudo mkdir -p /opt/microsoft/powershell/7 \
    && sudo tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7 \
    && sudo chmod +x /opt/microsoft/powershell/7/pwsh \
    && sudo ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh \
    # Activate Python env
    && python3 -m venv /opt/venv \
    && . /opt/venv/bin/activate \
    && pip install --upgrade pip \
    # Install AWS CLI
    && pip install awscli --upgrade \
    # Install Azure CLI
    && pip install --no-cache-dir azure-cli \
    # Deactivate Python env
    && deactivate \
    && apk del \
       cargo \
       gcc \
       libffi-dev \
       make \
       musl-dev \
       python3-dev \
       openssl-dev \
    && rm -rf /var/cache/apk/* \
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

ENV PATH="/opt/venv/bin:$PATH"

USER tfsvc_usr

RUN aws --version
RUN az --version