# docker build --no-cache -f Dockerfile -t erivando/pentaho-server-ce:latest .
# https://www.hitachivantara.com/en-us/products/pentaho-platform/data-integration-analytics/pentaho-community-edition.html

FROM openjdk:11-jdk

ENV SERVER_VERSION 9.4.0.0-343
ENV PENTAHO_HOME /opt/pentaho
ENV YOUR_DOMAIN google.com
ENV JAVA_OPTS -Duser.timezone=America/Fortaleza

RUN apt-get update && apt-get install -y netcat wget unzip git postgresql-client nano vim python3 python3-pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    curl -O https://bootstrap.pypa.io/get-pip.py && \
    python3 get-pip.py && \
    pip install awscli && \
    rm -f get-pip.py

RUN export JAVA_HOME='/usr/local/openjdk-11' && export PATH="$JAVA_HOME/bin:$PATH"

RUN mkdir ${PENTAHO_HOME} && \
    useradd -s /bin/bash -d ${PENTAHO_HOME} pentaho && \
    chown pentaho:pentaho ${PENTAHO_HOME} && \
    echo "pentaho ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Optional to cacerts error - start
RUN openssl s_client -showcerts -connect ${YOUR_DOMAIN}:443 </dev/null 2>/dev/null|openssl x509 -outform PEM > /tmp/ca.crt && \
    cp ${JAVA_HOME}/lib/security/cacerts /tmp/keystore.jks && \
    ${JAVA_HOME}/bin/keytool -import -trustcacerts -alias pentahoAlias -file /tmp/ca.crt -keystore /tmp/keystore.jks -noprompt -storepass changeit >/dev/null && \
    cp /tmp/keystore.jks ${JAVA_HOME}/lib/security/cacerts && \
    rm -rf /tmp/*
# Optional to cacerts error - end

RUN wget --no-check-certificate --progress=dot:giga https://privatefilesbucket-community-edition.s3.us-west-2.amazonaws.com/${SERVER_VERSION}/ce/server/pentaho-server-ce-${SERVER_VERSION}.zip -O /tmp/biserver-ce-${SERVER_VERSION}.zip && \
    unzip -q /tmp/biserver-ce-${SERVER_VERSION}.zip -d  $PENTAHO_HOME && \
    rm -f /tmp/biserver-ce-${SERVER_VERSION}.zip $PENTAHO_HOME/pentaho-server/promptuser.sh && \
    sed -i -e 's/\(exec ".*"\) start/\1 run/' $PENTAHO_HOME/pentaho-server/tomcat/bin/startup.sh && \
    chmod +x $PENTAHO_HOME/pentaho-server/start-pentaho.sh

USER pentaho

COPY config $PENTAHO_HOME/config
COPY scripts $PENTAHO_HOME/scripts

WORKDIR /opt/pentaho

EXPOSE 8080

LABEL \
  org.opencontainers.image.vendor="Erivando Sena" \
  org.opencontainers.image.title="Official openjdk image" \
  org.opencontainers.image.description="Pentaho Community Edition versão Open Source Pentaho BI Server em Docker" \
  org.opencontainers.image.version="${SERVER_VERSION}" \
  org.opencontainers.image.url="https://hub.docker.com/r/erivando/pentaho-server-ce" \
  org.opencontainers.image.source="https://github.com/erivandosena/pentaho-docker.git" \
  org.opencontainers.image.licenses="MIT" \
  org.opencontainers.image.maintainer="erivandosena@gmail.com"

CMD ["sh", "scripts/run.sh"]