#!/bin/bash
set -e

echo "INPUT_FILENAME: ${INPUT_FILENAME}"

# Check for required values
if [ -z "${INPUT_VID}" ] || [ -z "${INPUT_VKEY}" ]
then
    echo 'The Veracode API ID and KEY must be provided to submit a pipeline scan!'
    exit 1
fi

if [ -z "${INPUT_FILENAME}" ]
then
    echo 'A file must be provided to scan!'
    exit 1
fi

# Check optional parameters, and set commands
results=''
if [ -n "${INPUT_RESULTS}" ]
then
    results="--json_output_file ${INPUT_RESULTS}"
fi

baseline=''
if [ -n "${INPUT_BASELINE}" ] && [ -f "${INPUT_BASELINE}" ]
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
if [ ${ret} -eq -1 ]
then
    # We only capture -1 as that indicates a scan error. Code of -3 indicates a timeout, which we may suppress
    echo 'An error with the pipeline scan occurred!'
    exit -1
elif [ "${INPUT_ALLOWFAIL}" == 'false' ] || [ "${INPUT_ALLOWFAIL}" == '0' ]
then
    # Job will always succeed, regardless of scan results
    exit 0
else
    # Job will fail based on scan criteria and results
    exit ${ret}
fi
