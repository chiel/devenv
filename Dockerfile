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

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

CMD ["bash"]
