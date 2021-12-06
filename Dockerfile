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
        ca-certificates curl git jq silversearcher-ag tree

# install python 2
RUN apt-get install -y --no-install-recommends python2 \
    && curl -o- https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py | python2

# install python 3
RUN apt-get install -y --no-install-recommends python3 python3-pip

# install nvm + node + latest npm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash \
    && source $XDG_CONFIG_HOME/nvm/nvm.sh \
    && nvm install lts/* \
    && npm install -g npm

# install go
ENV PATH /usr/local/go/bin:$PATH
ENV GOLANG_VERSION 1.17.4
COPY --from=golang:1.17.4-bullseye /usr/local/go /usr/local/go

# install neovim + providers
ENV EDITOR=nvim
RUN apt-get install -y --no-install-recommends \
        autoconf automake cmake doxygen g++ gettext libtool libtool-bin make ninja-build pkg-config python2-dev unzip \
    && git clone -b stable --depth 1 --single-branch https://github.com/neovim/neovim /tmp/neovim \
    && cd /tmp/neovim \
    && make CMAKE_BUILD_TYPE=Release \
    && make install \
    && cd - \
    && rm -rf /tmp/neovim \
    && python2 -m pip install --no-cache-dir pynvim \
    && python3 -m pip install --no-cache-dir pynvim \
    && source $XDG_CONFIG_HOME/nvm/nvm.sh \
    && npm install -g neovim \
    && apt-get remove -y \
        autoconf automake cmake doxygen g++ gettext libtool libtool-bin make ninja-build pkg-config python2-dev unzip

# copy neovim config, install plugins
COPY .config .config
RUN git clone https://github.com/VundleVim/Vundle.vim.git $XDG_CONFIG_HOME/nvim/bundle/Vundle.vim \
    && nvim --headless +PluginInstall +qa \
    && nvim --headless +GoInstallBinaries +qa

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# set up home directory
RUN rm .bashrc .profile \
    && curl -o .git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash \
    && curl -o .git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh

COPY .bash_profile .
COPY .bashrc .

CMD ["bash"]
