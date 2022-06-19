FROM ubuntu:22.04 as build
ENV DEBIAN_FRONTEND=noninteractive TZ=Europe/Berlin

# Required packages
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
    software-properties-common gnupg && \
    add-apt-repository ppa:phoerious/keepassxc && \
    apt-get update && \
    apt-get -y install --no-install-recommends \
    curl bash git make expect openjdk-8-jdk ant maven python3 python3-dev python3-poetry python3-cachecontrol python3-pyscard \
    swig libpcsclite-dev build-essential opensc pcscd pcsc-tools vsmartcard-vpcd scdaemon keepassxc oathtool && \
    rm -rf /var/lib/apt/lists/* && \
    update-alternatives --set java /usr/lib/jvm/java-8-openjdk-*/jre/bin/java

# Download and install bats
RUN git clone --depth=1 https://github.com/bats-core/bats-core /app/tools/bats && \
    cd /app/tools/bats && \
    ./install.sh /usr/local

# Download JavaCard SDKs
RUN git clone --depth=1 https://github.com/martinpaljak/oracle_javacard_sdks /app/sdks

# Download and build jcardsim
RUN git clone --depth=1 --single-branch --branch fixes https://github.com/StarGate01/jcardsim.git /app/tools/jcardsim && \
    cd /app/tools/jcardsim && \
    JC_CLASSIC_HOME=/app/sdks/jc305u3_kit/ mvn initialize && \
    JC_CLASSIC_HOME=/app/sdks/jc305u3_kit/ mvn clean install

# Download and build yktool
RUN git clone --depth=1 --recursive https://github.com/arekinath/yktool.git /app/tools/yktool && \
    cd /app/tools/yktool && \
    make yktool.jar && \
    cp yktool.jar /usr/bin/

# Download and install ykman
RUN git clone --depth=1 --single-branch --branch test/fix-ccid https://github.com/StarGate01/yubikey-manager.git /app/tools/yubikey-manager && \
    cd /app/tools/yubikey-manager && \
    poetry install

# Download pcsc-ndef
RUN git clone --depth=1 https://github.com/Giraut/pcsc-ndef.git /app/tools/pcsc-ndef

WORKDIR /app
ENTRYPOINT [ "/bin/bash", "-c" ]