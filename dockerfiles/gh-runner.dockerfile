FROM ubuntu:24.04

# RUN apt-get update \
#     && apt-get upgrade -y \
#     # Install dependencies
#     && apt-get --no-install-recommends install -y \
#        apt-transport-https \
#        ca-certificates \
#        curl \
#        git \
#        gnupg \
#        jq \
#        libicu74 \
#        lsb-release \
#     # Install Docker
#     && curl --proto "=https" --tlsv1.2 -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
#     && echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
#        | tee /etc/apt/sources.list.d/docker.list > /dev/null \
#     && apt-get update \
#     && apt-get upgrade -y \
#     && apt-get --no-install-recommends install -y \
#        containerd.io \
#        docker-ce \
#        docker-ce-cli \
#     && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# WORKDIR /ado-agent/

# COPY ./script/bash/ado-agent-start.sh ./

# RUN chmod +x ./ado-agent-start.sh \
#     && groupadd -g 1992 ado_group \
#     && useradd -m -u 1999 -g 1992 ado_usr \
#     && chown ado_usr ./

# USER ado_usr

# ENTRYPOINT ["bash", "ado-agent-start.sh"]