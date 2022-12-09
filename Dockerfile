FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

# set version label
ARG BUILD_DATE
ARG VERSION
ARG CODE_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config"
# maven environment settings
ENV PATH="/opt/maven/bin:${PATH}"
ENV MAVEN_HOME="/opt/maven"

RUN \
  echo "**** install runtime dependencies ****" && \
  apt-get update && \
  apt-get install -y \
    git \
    jq \
    libatomic1 \
    nano \
    net-tools \
    netcat \
    sudo && \
  echo "**** install docker client ****" && \
  apt-get install -y docker.io && \
  echo "**** install jdk 17 ****" && \
  apt-get install -y openjdk-17-jdk && \
  echo "**** install maven ****" && \
  mkdir -p /opt/maven && \
  curl -o \
    /tmp/apache-maven-bin.tar.gz -L \
    "https://dlcdn.apache.org/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz" && \
  tar xf /tmp/apache-maven-bin.tar.gz -C \
    /opt/maven --strip-components=1 && \
  echo "**** install gradle ****" && \
  apt-get install -y gradle && \
  echo "**** install php ****" && \
  apt-get install -y software-properties-common && \
  add-apt-repository -y ppa:ondrej/php && \
  apt-get update && \
  apt-get install -y php8.2 libapache2-mod-php8.2 && \
  echo "**** install composer ****" && \
  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
  echo "**** install symfony ****" && \
  curl -sS https://get.symfony.com/cli/installer | bash && \
  echo "**** install code-server ****" && \
  if [ -z ${CODE_RELEASE+x} ]; then \
    CODE_RELEASE=$(curl -sX GET https://api.github.com/repos/coder/code-server/releases/latest \
      | awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^v||'); \
  fi && \
  mkdir -p /app/code-server && \
  curl -o \
    /tmp/code-server.tar.gz -L \
    "https://github.com/coder/code-server/releases/download/v${CODE_RELEASE}/code-server-${CODE_RELEASE}-linux-amd64.tar.gz" && \
  tar xf /tmp/code-server.tar.gz -C \
    /app/code-server --strip-components=1 && \
  echo "**** clean up ****" && \
  apt-get clean && \
  rm -rf \
    /config/* \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 8443
