FROM jenkins/ssh-agent:alpine-jdk17
RUN echo "\n---------------------------------------------------------------------------------------------------- DOCKER"; \
    apk add docker; \
    addgroup username docker; \
    rc-update add docker default; \
    service docker start; \
    #chmod a+r /etc/apt/keyrings/docker.gpg; \
    #echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null; \
    #apt-get update -y; \
    #apt-cache madison docker-ce | awk '{ print $3 }'; \
    #VERSION_STRING=5:24.0.0-1~ubuntu.22.04~jammy; \
    #apt-get install -y docker-ce=$VERSION_STRING docker-ce-cli=$VERSION_STRING containerd.io docker-buildx-plugin docker-compose-plugin; \
    docker --version;

# ssh-keygen -f ~/.ssh/jenkins_agent_key

# clear && docker build -t personal_agent .
# docker tag personal_agent sennar19/personal_agent:1.0.0
# docker run -d --rm --name=agent2 -p 2223:22 -e "JENKINS_AGENT_SSH_PUBKEY=ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDkvASeoTyt2dJMXZe3Ovy3qXRJx3kwsnrLMlAQENk9KYj6BErb6sdZWFinIkTKICAXzmEOcCOLTXqpgCS6Fxnh24MHQYYcOzQ31QofVy5sN6thfq44l40BRXyJ3K6Kp7cX/el9YSYEDDthNq+nKWLffIqxJjoC1DUl6vUDD7oGWUqL8YzMtWy54SV5ukJwCrygee9f6zB44S4k4obNirWIGU3d+Ty8l7IqoCCBlyLKuqVxg59OWEpJpRTv8nmH+0ZF3qcla5tUGiDXaILSK6rFyFm5UVAhLj5y1+Dugj4Zu8KHbuLOyJFFdT2Xj4rOnpiMdu1LaHeMHcbctyeLEqDsb8rRGbRxY094ugsWBpsMEVvyxLutOj3MRwrhTxGKiEBE3GpkXY12LPHeWux0CosGoI3zwe0eWZ7jXnR9Z2ECisouFAv9r60HfD3ytH3csIw5UC/HKsDz11VBH/uD0kJvRoBMnRFzgduzaIMHmuczf6K/S18qp7nD5vKQ2M9YfL0= cristiano@N-HP0721-0030" sennar19/personal_agent:1.0.0
# docker push sennar19/personal_agent:1.0.0