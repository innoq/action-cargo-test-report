#!/bin/sh

: ${1:?}

test -n "${GITHUB_WORKSPACE}" && cd ${GITHUB_WORKSPACE}

mkdir -p junit-reports/
(
set -x
cat "${1}"|cargo2junit > junit-reports/TEST-all.xml
)
SUMMARY="$(markdown-summary.sh ${1})"
echo "::set-output name=summary::${SUMMARY}"
