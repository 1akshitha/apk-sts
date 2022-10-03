FROM ballerina/ballerina:2201.2.0 AS ballerina-builder
USER root
ADD . /src
WORKDIR /src

RUN bal build

FROM ubuntu:20.04

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# install JDK Dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata curl ca-certificates fontconfig locales python-is-python3 \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_VERSION jdk-11.0.14+9

RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
        amd64|i386:x86-64) \
         ESUM='1189bee178d11402a690edf3fbba0c9f2ada1d3a36ff78929d81935842ef24a9'; \
         BINARY_URL='https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.14%2B9/OpenJDK11U-jdk_x64_linux_hotspot_11.0.14_9.tar.gz'; \
         ;; \
        aarch64|arm64) \
         ESUM='0ba188a2a739733163cd0049344429d2284867e04ca452879be24f3b54320c9a'; \
         BINARY_URL='https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.14%2B9/OpenJDK11U-jdk_aarch64_linux_hotspot_11.0.14_9.tar.gz'; \
         ;; \
        *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \ 
    esac; \
    curl -LfsSo /tmp/openjdk.tar.gz ${BINARY_URL}; \
    echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/java/openjdk; \
    cd /opt/java/openjdk; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    rm -rf /tmp/openjdk.tar.gz;

ENV JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:$PATH"

RUN echo Verifying install ... \
    && echo javac --version && javac --version \
    && echo java --version && java --version \
    && echo Complete.

ARG USER=wso2carbon
ARG USER_ID=802
ARG USER_GROUP=wso2
ARG USER_GROUP_ID=802
ARG USER_HOME=/home/${USER}

RUN groupadd --system -g ${USER_GROUP_ID} ${USER_GROUP} && useradd --system --create-home --home-dir ${USER_HOME} --no-log-init -g ${USER_GROUP_ID} -u ${USER_ID} ${USER}

# ADD . ${USER_HOME}
COPY --from=ballerina-builder /src/target/bin/apk.jar ${USER_HOME}

RUN chown wso2carbon /home/wso2carbon/apk.jar
# RUN chown ballerina /home/ballerina/apim.jar

EXPOSE 9443
USER wso2carbon
WORKDIR ${USER_HOME}

CMD java -jar apk.jar
