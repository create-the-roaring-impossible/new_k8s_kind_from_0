FROM ubuntu:24.04

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get --no-install-recommends install -y \
       curl \
       git \
       jq \
       libicu74 \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

WORKDIR /ado-agent/

COPY ./script/bash/ado-agent-start.sh ./

RUN chmod +x ./ado-agent-start.sh \
    && useradd ado_usr \
    && chown ado_usr ./

USER ado_usr

ENTRYPOINT ["bash", "ado-agent-start.sh"]