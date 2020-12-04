FROM openjdk:11.0.6-jdk

USER root

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -y update \
   && apt-get -y install fontconfig \
   && apt-get -y install ttf-dejavu \
   && fc-cache -f
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

#WORKDIR /opt/tools/jmeter

#ENV JAVA_OPTS="-Xms2G -Xmx2G"
#ENV JVM_ARGS="-Xms2G -Xmx2G"

RUN echo 'echo "|====================================|"' >> /opt/entrypoint.sh
RUN echo 'echo "|========== ENV VALUES ==============|"' >> /opt/entrypoint.sh
RUN echo 'echo "|====================================|"' >> /opt/entrypoint.sh
RUN echo 'echo "| PROPS_PATH:    " ${PROPS_PATH}' >> /opt/entrypoint.sh
RUN echo 'echo "| JMX_FILE:      " ${JMX_FILE}' >> /opt/entrypoint.sh
RUN echo 'echo "| JTL_FILE:      " ${JTL_FILE}' >> /opt/entrypoint.sh
RUN echo 'echo "| RUN_TEST:      " ${RUN_TEST}' >> /opt/entrypoint.sh
RUN echo 'echo "| MERGE_RESULTS: " ${MERGE_RESULTS}' >> /opt/entrypoint.sh
RUN echo 'echo "| REPORT_FOLDER: " ${REPORT_FOLDER}' >> /opt/entrypoint.sh
RUN echo 'echo "| HEAP:          " ${HEAP}' >> /opt/entrypoint.sh
RUN echo 'echo "|====================================|"' >> /opt/entrypoint.sh

RUN echo 'if [ "${RUN_TEST}" = false ] ; then' >> /opt/entrypoint.sh
RUN echo '    echo "--- ONLY REPORT MODE ---"' >> /opt/entrypoint.sh
RUN echo '    if [ "${MERGE_RESULTS}" = true ] ; then' >> /opt/entrypoint.sh
RUN echo '        echo "+++ MERGING RESULTS +++"' >> /opt/entrypoint.sh
RUN echo '        python /opt/tools/merge-results.py' >> /opt/entrypoint.sh
RUN echo '    fi' >> /opt/entrypoint.sh
RUN echo 'else' >> /opt/entrypoint.sh
RUN echo '    echo "+++ TESTING +++"' >> /opt/entrypoint.sh
RUN echo '    ${JMETER_HOME}/bin/jmeter -n -p /opt/jmx/${PROPS_PATH} -t /opt/jmx/${JMX_FILE} -l ${RESULT_HOME}/${JTL_FILE} -j ${RESULT_HOME}/log-file.log' >> /opt/entrypoint.sh
RUN echo 'fi' >> /opt/entrypoint.sh

RUN echo 'echo "--- MOVING OLD REPORTS ---"' >> /opt/entrypoint.sh
RUN echo 'mv ${RESULT_HOME}/${REPORT_FOLDER} ${RESULT_HOME}/${REPORT_FOLDER}-$(date +"%Y%m%d%H%M")' >> /opt/entrypoint.sh

RUN echo 'echo "+++ GENERATING REPORT +++"' >> /opt/entrypoint.sh
RUN echo 'if [ "${MERGE_RESULTS}" = true ] ; then' >> /opt/entrypoint.sh
RUN echo '    ${JMETER_HOME}/bin/jmeter -g ${RESULT_HOME}/mergedResults.jtl -o ${RESULT_HOME}/${REPORT_FOLDER}' >> /opt/entrypoint.sh
RUN echo 'else' >> /opt/entrypoint.sh
RUN echo '    ${JMETER_HOME}/bin/jmeter -g ${RESULT_HOME}/${JTL_FILE} -o ${RESULT_HOME}/${REPORT_FOLDER}' >> /opt/entrypoint.sh
RUN echo 'fi' >> /opt/entrypoint.sh


ENTRYPOINT [ "sh", "/opt/entrypoint.sh"]
