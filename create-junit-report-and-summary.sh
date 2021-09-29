#!/bin/sh

: ${1:?}
results_file=${GITHUB_WORKSPACE}/$1

test -n "${GITHUB_WORKSPACE}" && cd ${GITHUB_WORKSPACE}

mkdir -p junit-reports/
(
set -x
cat "${results_file}"|cargo2junit > junit-reports/TEST-all.xml
)
SUMMARY="$(markdown-summary.sh ${results_file})"
echo "::set-output name=summary::${SUMMARY}"
