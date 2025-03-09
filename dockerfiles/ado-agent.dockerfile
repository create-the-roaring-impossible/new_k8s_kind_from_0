FROM ubuntu:24.04

RUN apt update \
    && apt upgrade -y \
    && apt install -y \
       curl \
       git \
       jq \
       libicu74 \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

WORKDIR /ado-agent/

COPY ./script/bash/ado-agent-start.sh ./

RUN chmod +x ./ado-agent-start.sh \
    && useradd agent \
    && chown agent ./

USER agent

# Another option is to run the agent as root.
# ENV AGENT_ALLOW_RUNASROOT="true"

ENTRYPOINT ["bash", "ado-agent-start.sh"]