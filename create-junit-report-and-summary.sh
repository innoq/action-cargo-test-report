#!/bin/sh

: ${1:?}
results_file=${GITHUB_WORKSPACE}/$1

test -n "${GITHUB_WORKSPACE}" && cd ${GITHUB_WORKSPACE}

mkdir -p junit-reports/
(
set -ex -o pipefail
cat "${results_file}"|junitify --out junit-reports
cd junit-reports/ && ls *.xml|xargs -I% -n1 mv % TEST-%
find .
)


SUMMARY="$(markdown-summary.sh ${results_file})"
echo "::set-output name=summary::${SUMMARY}"
