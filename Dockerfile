FROM ubuntu:22.04 as build
ENV DEBIAN_FRONTEND=noninteractive TZ=Europe/Berlin

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
    bash git make expect \
    openjdk-8-jdk ant maven \
    opensc pcscd pcsc-tools vsmartcard-vpcd \
    gnupg scdaemon && \
    rm -rf /var/lib/apt/lists/*

RUN update-alternatives --set java /usr/lib/jvm/java-8-openjdk-*/jre/bin/java
WORKDIR /app

# Download JavaCard SDKs
RUN git clone --depth=1 https://github.com/martinpaljak/oracle_javacard_sdks /app/sdks

# Build and install jcardsim
RUN git clone https://github.com/arekinath/jcardsim.git /app/tools/jcardsim && \
    cd /app/tools/jcardsim && \
    git checkout 4d9513c858fb97333c17cab342c8cbffebe7b539 && \
    JC_CLASSIC_HOME=/app/sdks/jc305u3_kit/ mvn initialize && \
    JC_CLASSIC_HOME=/app/sdks/jc305u3_kit/ mvn clean install

WORKDIR /app
ENTRYPOINT [ "/bin/bash", "-c" ]