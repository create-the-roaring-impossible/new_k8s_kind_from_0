FROM jenkins/ssh-agent:alpine-jdk17

RUN echo "\n---------------------------------------------------------------------------------------------------- DOCKER"; \
    apk add docker; \
    addgroup username docker; \
    rc-update add docker default; \
    service docker start; \
    docker --version;

    RUN echo "\n---------------------------------------------------------------------------------------------------- UNZIP"; \
        apk add unzip;