FROM ubuntu:22.04 as build
ENV DEBIAN_FRONTEND=noninteractive TZ=Europe/Berlin

# Required packages
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
    software-properties-common gnupg && \
    add-apt-repository ppa:phoerious/keepassxc && \
    apt-get update && \
    apt-get -y install --no-install-recommends \
    bash git make expect openjdk-8-jdk ant maven opensc pcscd pcsc-tools vsmartcard-vpcd scdaemon keepassxc && \
    rm -rf /var/lib/apt/lists/* && \
    update-alternatives --set java /usr/lib/jvm/java-8-openjdk-*/jre/bin/java

# Install bats
RUN git clone --depth=1 https://github.com/bats-core/bats-core /app/tools/bats && \
    cd /app/tools/bats && \
    ./install.sh /usr/local

# Download JavaCard SDKs
RUN git clone --depth=1 https://github.com/martinpaljak/oracle_javacard_sdks /app/sdks

# Build and install jcardsim
RUN git clone https://github.com/arekinath/jcardsim.git /app/tools/jcardsim && \
    cd /app/tools/jcardsim && \
    git checkout 4d9513c858fb97333c17cab342c8cbffebe7b539 && \
    JC_CLASSIC_HOME=/app/sdks/jc305u3_kit/ mvn initialize && \
    JC_CLASSIC_HOME=/app/sdks/jc305u3_kit/ mvn clean install

# Build and install yktool
RUN git clone --depth=1 --recursive https://github.com/arekinath/yktool.git /app/tools/yktool && \
    cd /app/tools/yktool && \
    make yktool.jar && \
    cp yktool.jar /usr/bin/

WORKDIR /app
ENTRYPOINT [ "/bin/bash", "-c" ]