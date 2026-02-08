# DESCRIPTION: Terraform/OpenTofu container
# REQUIREMENTS: Docker
# USAGE: docker build -f [<path>/]tf.dockerfile -t tf[:<tag>] . --debug
# TEST: docker run -it --rm tf[:<tag>] /bin/bash
# AUTHORS: Matteo Cristiano
# VERSION: 2.00
# DATE: 2026-08-02

ARG TF_VERSION=1.14.4
ARG TOFU_VERSION=1.11.4
ARG TF_DOC_VERSION=0.20.0
ARG ALPINE_VERSION=3.23.3
# ARG TFSEC_VERSION=1.28.13

FROM hashicorp/terraform:${TF_VERSION} AS terraform
FROM ghcr.io/opentofu/opentofu:${TOFU_VERSION}-minimal AS tofu
FROM quay.io/terraform-docs/terraform-docs:${TF_DOC_VERSION} AS terraform-docs

FROM alpine:${ALPINE_VERSION} AS base

# Add metadata labels
LABEL description="Terraform/OpenTofu container"
LABEL maintainer="Matteo Cristiano"
LABEL version="2.00"

USER root

RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        bash \
#         ca-certificates \
#         cargo \
#         coreutils \
#         curl \
#         gcc \
        git \
#         krb5-libs \
#         less \
#         libffi-dev \
#         libintl \
#         libssl3 \
#         lttng-ust \
#         make \
#         musl-dev \
#         ncurses-terminfo-base \
#         openssh-client \
#         openssl-dev \
#         py3-pip \
#         python3 \
#         python3-dev \
        sudo \
#         tar \
#         tzdata \
#         userspace-rcu \
#         zlib \
        wget

FROM base AS tools

# Install PowerShell
ARG PWSH_VERSION=7.5.4
ADD "https://github.com/PowerShell/PowerShell/releases/download/v${PWSH_VERSION}/powershell-${PWSH_VERSION}-linux-musl-x64.tar.gz" /tmp/powershell.tar.gz
RUN apk add --no-cache \
        icu-libs \
        libgcc \
        libstdc++ && \
    sudo mkdir -p /opt/microsoft/powershell/7 && \
    sudo tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7 && \
    sudo chmod +x /opt/microsoft/powershell/7/pwsh && \
    sudo ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh
    # && \
# # Activate Python env and upgrade PIP
#     python3 -m venv /opt/venv && \
#     . /opt/venv/bin/activate && \
#     pip install --upgrade --no-cache-dir pip && \
# # Install AWS CLI
#     pip install --upgrade --no-cache-dir awscli && \
# # Install Azure CLI
#     pip install  --upgrade --no-cache-dir azure-cli && \
# # Deactivate Python env
#     deactivate

# Copy the terraform binary
COPY --from=terraform /bin/terraform /bin/terraform

# Copy the tofu binary
COPY --from=tofu /usr/local/bin/tofu /usr/local/bin/tofu

# Copy the terraform-docs binary
COPY --from=terraform-docs /usr/local/bin/terraform-docs /usr/local/bin/terraform-docs

# # Install tfsec # TODO to replace with ASDASDASD
# ADD "https://github.com/aquasecurity/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-linux-amd64" /usr/local/bin/tfsec
# RUN chmod +x /usr/local/bin/tfsec && \
#     apk del .deps \
#         gcc \
#         libffi-dev \
#         make \
#         musl-dev \
#         openssl-dev \
#         python3-dev && \
#     apk cache clean && \
#     rm -rf /var/cache/apk/* /tmp/* /root/.cache

FROM tools AS final

# ENV PATH="/opt/venv/bin:$PATH"