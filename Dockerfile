FROM jenkins/inbound-agent:latest

LABEL maintainer="slb6113@gmail.com"

USER root
RUN apt-get update && apt-get install -y \
    unzip \
    curl;
RUN rm -rf /var/lib/apt/lists/*;

USER jenkins
WORKDIR /home/jenkins/agent

CMD ["jenkins-agent"]