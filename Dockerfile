FROM jenkins/inbound-agent:latest

LABEL maintainer="slb6113@gmail.com"

USER root
RUN apt-get update && apt-get install -y \
    software-properties-common \zip \
    python3-launchpadlib \
    unzip \
    git \
    curl;
RUN rm -rf /var/lib/apt/lists/*;
RUN add-apt-repository ppa:git-core/ppa;
RUN apt update;
RUN apt install --only-upgrade git/;
RUN git --version;

USER jenkins
WORKDIR /home/jenkins/agent

CMD ["jenkins-agent"]