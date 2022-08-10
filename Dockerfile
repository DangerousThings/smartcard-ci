FROM ubuntu:22.04 as build
ENV DEBIAN_FRONTEND=noninteractive TZ=Europe/Berlin

# Required packages
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
    software-properties-common gnupg && \
    add-apt-repository ppa:phoerious/keepassxc && \
    apt-get update && \
    apt-get -y install --no-install-recommends \
    curl bash git expect jq openjdk-8-jdk ant maven \
    python3 python3-pip python3-dev python3-poetry python3-cachecontrol \
    swig opensc pcscd pcsc-tools vsmartcard-vpcd scdaemon keepassxc oathtool \
    build-essential make cmake pkg-config \
    libpcsclite-dev libcbor-dev libudev-dev libz-dev libssl-dev libcurl4-openssl-dev libjansson-dev && \
    rm -rf /var/lib/apt/lists/* && \
    update-alternatives --set java /usr/lib/jvm/java-8-openjdk-*/jre/bin/java

# Install Python packages
RUN pip3 install ndeflib pyasn1 asn1 cryptography pyscard

# Download and install bats
RUN git clone --single-branch --depth=1 https://github.com/bats-core/bats-core /app/tools/bats && \
    cd /app/tools/bats && \
    ./install.sh /usr/local

# Download JavaCard SDKs
RUN git clone --single-branch --depth=1 https://github.com/martinpaljak/oracle_javacard_sdks /app/sdks

# Download and build jcardsim
RUN git clone --single-branch --depth=1 https://github.com/StarGate01/jcardsim.git /app/tools/jcardsim && \
    cd /app/tools/jcardsim && \
    JC_CLASSIC_HOME=/app/sdks/jc305u3_kit/ mvn initialize && \
    JC_CLASSIC_HOME=/app/sdks/jc305u3_kit/ mvn clean install

# Download and build yktool
RUN git clone --single-branch --depth=1 --recursive https://github.com/arekinath/yktool.git /app/tools/yktool && \
    cd /app/tools/yktool && \
    make yktool.jar && \
    cp yktool.jar /usr/bin/

# Download and install ykman (dev version)
RUN git clone --single-branch --depth=1 https://github.com/Yubico/yubikey-manager.git /app/tools/yubikey-manager && \
    cd /app/tools/yubikey-manager && \
    poetry install

# Download pcsc-ndef
RUN git clone --single-branch --depth=1 https://github.com/Giraut/pcsc-ndef.git /app/tools/pcsc-ndef

# Download and install libfido2
RUN git clone --single-branch --depth=1 https://github.com/Yubico/libfido2.git /app/tools/libfido2 && \
    cd /app/tools/libfido2 && \
    cmake -DUSE_PCSC=ON -B build && \
    make -C build -j$(nproc) && \
    make -C build install && \
    ldconfig

# Download and install fido2-webauthn-client
RUN git clone --single-branch --depth=1 https://github.com/martelletto/fido2-webauthn-client.git /app/tools/fido2-webauthn-client && \
    cd /app/tools/fido2-webauthn-client && \
    cmake -B build && \
    make -C build -j$(nproc) && \
    cp build/fido2-webauthn-client /usr/bin/

# Download fido-attestation-loader
RUN git clone https://github.com/StarGate01/fido-attestation-loader /app/tools/fido-attestation-loader && \
    cd /app/tools/fido-attestation-loader && \
    git checkout 7651de63c714fa9ef54af2555046372967c65fe6

WORKDIR /app
ENTRYPOINT [ "/bin/bash", "-c" ]