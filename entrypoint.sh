echo "|====================================|"
echo "|========== ENV VALUES ==============|"
echo "|====================================|"
echo "| PROPS_PATH:           " ${PROPS_PATH}
echo "| JMX_FILE:             " ${JMX_FILE}
echo "| YML_FILE:             " ${YML_FILE}
echo "| JTL_FILE:             " ${JTL_FILE}
echo "| RUN_TEST:             " ${RUN_TEST}
echo "| USE_BLAZE_METER:      " ${USE_BLAZE_METER}
echo "| MERGE_RESULTS:        " ${MERGE_RESULTS}
echo "| REPORT_FOLDER:        " ${REPORT_FOLDER}
echo "| HEAP:                 " ${HEAP}
echo "|====================================|"
if [ "${RUN_TEST}" = false ] ; then
    echo "--- ONLY REPORT MODE ---"
    if [ "${MERGE_RESULTS}" = true ] ; then
        echo "+++ MERGING RESULTS +++"
        python3 /opt/tools/merge-results.py
    fi
else
    echo "+++ TESTING +++"
    if [ "${USE_BLAZE_METER}" = true ] ; then
        if [ -z "${YML_FILE}" ] ; then
            echo "---> RUNNING BY JMX FILE"
            bzt /opt/jmx/${JMX_FILE}
        else
            echo "---> RUNNING BY YML FILE"
            bzt /opt/jmx/${YML_FILE}
        fi
    else 
        ${JMETER_HOME}/bin/jmeter -n -p /opt/jmx/${PROPS_PATH} -t /opt/jmx/${JMX_FILE} -l ${RESULT_HOME}/${JTL_FILE} -j ${RESULT_HOME}/log-file.log 
    fi
fi

echo "--- MOVING OLD REPORTS ---"
mv ${RESULT_HOME}/${REPORT_FOLDER} ${RESULT_HOME}/${REPORT_FOLDER}-$(date +"%Y%m%d%H%M")

echo "+++ GENERATING REPORT +++"
if [ "${MERGE_RESULTS}" = true ] ; then
    ${JMETER_HOME}/bin/jmeter -g ${RESULT_HOME}/mergedResults.jtl -o ${RESULT_HOME}/${REPORT_FOLDER}
else
    ${JMETER_HOME}/bin/jmeter -g ${RESULT_HOME}/${JTL_FILE} -o ${RESULT_HOME}/${REPORT_FOLDER}
fi