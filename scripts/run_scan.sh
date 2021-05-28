#!/bin/sh -l

results=''
if [ -n "${INPUT_RESULTS}" ]
then
    results="--json_output_file ${INPUT_RESULTS}"
fi

baseline=''
if [ -n "${INPUT_BASELINE}" ]
then
    baseline="--baseline_file ${INPUT_BASELINE}"
fi

timeout=''
if [ -n "${INPUT_TIMEOUT}" ]
then
    timeout="--timeout ${INPUT_TIMEOUT}"
fi

severity=''
if [ -n "${INPUT_SEVERITY}" ]
then
    severity="--fail_on_severity=\"${INPUT_SEVERITY}\""
fi

cwe=''
if [ -n "${INPUT_CWE}" ]
then
    cwe="--fail_on_cwe=\"${INPUT_CWE}\""
fi

appid=''
if [ -n "${INPUT_APPID}" ]
then
    appid="-aid ${INPUT_APPID}"
fi

# Run Veracode pipeline scan
java -jar pipeline-scan.jar -vid "${INPUT_VID}" -vkey "${INPUT_VKEY}" -f "${INPUT_FILENAME}" \
    "${severity}" "${cwe}" "${timeout}" "${appid}" "${results}" "${baseline}" 

# Save return code for optional exit status
ret=$?

# Determine exit status
if [ "${INPUT_ALLOWFAIL}" == 'false' ] || [ "${INPUT_ALLOWFAIL}" == '0' ]
then
    exit 0  # Job will always succeed, regardless of scan results
else
    exit "$ret"  # Job will fail based on scan criteria and results
fi
