# syntax=docker/dockerfile:1.0.0-experimental

FROM debian:stable-slim

WORKDIR /root

ENV HISTFILESIZE=10000
ENV HISTSIZE=10000
ENV TZ=Europe/Amsterdam
ENV XDG_CONFIG_HOME="/root/.config"

SHELL ["/bin/bash", "-c", "-o", "pipefail"]

# upgrade all installed packages
RUN apt-get update && apt-get upgrade -y

# generate en_GB.UTF-8 locale
ENV LC_ALL=en_GB.UTF-8
RUN apt-get install -y --no-install-recommends locales \
    && sed -i 's/^# *\(en_GB.UTF-8\)/\1/' /etc/locale.gen \
    && locale-gen

# install development packages
RUN apt-get install -y --no-install-recommends \
        ca-certificates curl git jq tree

# install python 2
RUN apt-get install -y --no-install-recommends python2 \
    && curl -o- https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py | python2

# install python 3
RUN apt-get install -y --no-install-recommends python3 python3-pip

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

CMD ["bash"]
