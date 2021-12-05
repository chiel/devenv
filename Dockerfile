# syntax=docker/dockerfile:1.0.0-experimental

FROM debian:stable-slim

SHELL ["/bin/bash", "-c", "-o", "pipefail"]

# upgrade all installed packages
RUN apt-get update && apt-get upgrade -y

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

CMD ["bash"]
