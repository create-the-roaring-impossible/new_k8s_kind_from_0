FROM jenkins/agent:latest

USER root

RUN echo "----------------------------------------------------------------------------------------------------"
RUN apt-get update && apt-get install -y unzip
RUN unzip --help

USER jenkins