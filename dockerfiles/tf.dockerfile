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
ARG TFSEC_VERSION=v1.28.14
ARG ALPINE_VERSION=3.23.3

FROM hashicorp/terraform:${TF_VERSION} AS terraform

FROM ghcr.io/opentofu/opentofu:${TOFU_VERSION}-minimal AS tofu

FROM quay.io/terraform-docs/terraform-docs:${TF_DOC_VERSION} AS terraform-docs

FROM ghcr.io/aquasecurity/tfsec-alpine:${TFSEC_VERSION} AS tfsec

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
        curl \
        git \
        sudo \
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

# Copy the terraform binary
COPY --from=terraform /bin/terraform /bin/terraform

# Copy the tofu binary
COPY --from=tofu /usr/local/bin/tofu /usr/local/bin/tofu

# Copy the terraform-docs binary
COPY --from=terraform-docs /usr/local/bin/terraform-docs /usr/local/bin/terraform-docs

# Copy the tfsec binary
COPY --from=tfsec /usr/bin/tfsec /usr/bin/tfsec

# Install AWS cli
ARG AWS_VERSION=2.32.7
RUN apk add --no-cache \
    aws-cli=="${AWS_VERSION}-r0"

# Install Azure cli
ARG AZURE_VERSION=2.83.0
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
#         ca-certificates \
        cargo \
#         coreutils \
        gcc \
#         krb5-libs \
#         less \
        libffi-dev \
#         libintl \
#         libssl3 \
#         lttng-ust \
        make \
        musl-dev \
#         ncurses-terminfo-base \
#         openssh-client \
        openssl-dev \
        py3-pip \
        python3 \
        python3-dev && \
#         tar \
#         tzdata \
#         userspace-rcu \
#         zlib \
    pip install --upgrade pip && \
    pip install azure-cli=="${AZURE_VERSION}"

# Install GCP cli
# TODO: add GCP cli installation

FROM tools AS final