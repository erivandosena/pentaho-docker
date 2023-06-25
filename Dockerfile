FROM openjdk:22-jdk

LABEL maintainer="Erivando Sena"

# Init ENV
ENV BISERVER_VERSION 5.4
ENV BISERVER_TAG 5.4.0.1-130
ENV PENTAHO_HOME /opt/pentaho

# Apply JAVA_HOME
ENV JAVA_HOME /usr/local/openjdk-17

# Install Dependencies
RUN apt-get update && apt-get install -y zip netcat wget unzip git postgresql-client-9.4 vim python python-pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    curl -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    pip install awscli && \
    rm -f get-pip.py

# Create User and Directory
RUN mkdir ${PENTAHO_HOME} && \
    useradd -s /bin/bash -d ${PENTAHO_HOME} pentaho && \
    chown pentaho:pentaho ${PENTAHO_HOME}

USER pentaho

# Download Pentaho BI Server
RUN wget --progress=dot:giga http://downloads.sourceforge.net/project/pentaho/Business%20Intelligence%20Server/${BISERVER_VERSION}/biserver-ce-${BISERVER_TAG}.zip -O /tmp/biserver-ce-${BISERVER_TAG}.zip && \
    unzip -q /tmp/biserver-ce-${BISERVER_TAG}.zip -d  $PENTAHO_HOME && \
    rm -f /tmp/biserver-ce-${BISERVER_TAG}.zip $PENTAHO_HOME/biserver-ce/promptuser.sh && \
    sed -i -e 's/\(exec ".*"\) start/\1 run/' $PENTAHO_HOME/biserver-ce/tomcat/bin/startup.sh && \
    chmod +x $PENTAHO_HOME/biserver-ce/start-pentaho.sh

COPY config $PENTAHO_HOME/config
COPY scripts $PENTAHO_HOME/scripts
RUN chmod +x $PENTAHO_HOME/scripts/*.sh

WORKDIR /opt/pentaho

EXPOSE 8080

CMD ["sh", "scripts/run.sh"]
