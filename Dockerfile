FROM openjdk:11.0.6-jdk

USER root

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -y update \
   && apt-get -y install fontconfig \
   && apt-get -y install ttf-dejavu \
   && apt-get -y install python3 python3-pip \
   && fc-cache -f

RUN python3 -m pip install bzt

ENV DEBIAN_FRONTEND teletype

RUN mkdir /opt/tools

ARG JMETER_VERSION=5.3

RUN mkdir -p /opt/tmp
RUN cd /opt/tmp 
RUN wget https://downloads.apache.org/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.zip
RUN unzip apache-jmeter-${JMETER_VERSION}.zip
RUN mv apache-jmeter-${JMETER_VERSION} /opt/tools/jmeter
RUN rm -rf /opt/tmp

RUN wget https://jmeter-plugins.org/get/ -O /opt/tools/jmeter/lib/ext/jmeter-plugins-manager.jar
RUN wget https://repo1.maven.org/maven2/kg/apc/cmdrunner/2.2/cmdrunner-2.2.jar -P /opt/tools/jmeter/lib/
RUN java -cp /opt/tools/jmeter/lib/ext/jmeter-plugins-manager.jar org.jmeterplugins.repository.PluginManagerCMDInstaller
RUN /opt/tools/jmeter/bin/./PluginsManagerCMD.sh install jpgc-webdriver

ENV PROPS_PATH 'user.properties'
ENV JMX_FILE 'test.jmx'
ENV JTL_FILE 'result.jtl'
ENV RUN_TEST 'true'
ENV MERGE_RESULTS 'false'
ENV REPORT_FOLDER 'report'
ENV HEAP '-Xms2g -Xmx2g -XX:MaxMetaspaceSize=256m'

ENV JMETER_HOME "/opt/tools/jmeter"
ENV RESULT_HOME "/opt/results"

RUN export -p PATH=${JMETER_HOME}/bin:$PATH

RUN mkdir -p ${RESULT_HOME}
RUN mkdir -p /opt/jmx

ADD merge-results.py /opt/tools/merge-results.py
ADD entrypoint.sh /opt/entrypoint.sh

WORKDIR /opt/jmx

CMD [ "/bin/bash", "/opt/entrypoint.sh"]
