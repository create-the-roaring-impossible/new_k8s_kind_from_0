FROM alpine:3.21.3

RUN apk update \
    && apk upgrade \
    # Install dependencies
    && apk add --no-cache \
       bash \
       git
    # Install Terraform

USER tf_usr