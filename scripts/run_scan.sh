#!/bin/bash
set -e

# Number regex
num='^[0-9]+$'

# Check for required values
if [ -z "${INPUT_VID}" ] || [ -z "${INPUT_VKEY}" ]
then
    echo 'The Veracode API ID and KEY must be provided to submit a pipeline scan!'
    exit 1
fi

if [ -z "${INPUT_FILENAME}" ] && [ -f "${INPUT_FILENAME}" ]
then
    echo 'A file must be provided to scan!'
    exit 1
fi

optional_args=()

# Check optional parameters, and set commands
if [ -n "${INPUT_RESULTS}" ]
then
    optional_args+=( --json_output_file \""${INPUT_RESULTS}"\" )
fi

if [ -n "${INPUT_BASELINE}" ] && [ -f "${INPUT_BASELINE}" ]
then
    optional_args+=( --baseline_file \""${INPUT_BASELINE}"\" )
fi

if [ -n "${INPUT_TIMEOUT}" ] && [[ ${INPUT_TIMEOUT} =~ ${num} ]]
then
    optional_args+=( --timeout "${INPUT_TIMEOUT}" )
fi

if [ -n "${INPUT_SEVERITY}" ]
then
    optional_args+=( --fail_on_severity=\""${INPUT_SEVERITY}"\" )
fi

if [ -n "${INPUT_CWE}" ]
then
    optional_args+=( --fail_on_cwe=\""${INPUT_CWE}"\" )
fi

if [ -n "${INPUT_APPID}" ] && [[ ${INPUT_APPID} =~ ${num} ]]
then
    optional_args+=( -aid "${INPUT_APPID}" )
fi

echo "Executing Pipeline Scan with the following optional parameters:"
echo "${optional_args[@]}"

# Run Veracode pipeline scan
set -x
java -jar pipeline-scan.jar -vid "${INPUT_VID}" -vkey "${INPUT_VKEY}" -f "${INPUT_FILENAME}" "${optional_args[@]}"

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
