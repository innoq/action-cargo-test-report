#!/bin/sh

cargo_test_results_file=$1

: ${cargo_test_results_file:?}

# cargo output has some nasty combination of escape characters which confuse bash
sed -i.bak -e 's/\\"//g' ${cargo_test_results_file}

echo "|  |test  |duration|" >  results.md
echo "|--|------|-------:|" >> results.md
while read line
do
    title=$(echo "${line}"|jq -r .name)
    if [ "${title}" = "${title:0:80}" ]
    then
        name="${title}"
    else
        name="${title:0:77}..."
    fi
    duration_title=$(echo "${line}"|jq -r ".exec_time" 2>/dev/null)
    duration=$(printf "%.2f" ${duration_title} 2>/dev/null)

    echo "${line}"|jq -r 'if .event != "started" and .type != "suite" and .event == "ok"              then ["|","<span title=\"OK\"             >✅</span>|", "<span title=\"'${title}'\">'${name}'</span>","|","<tt title=\"'${duration_title}' seconds\">'${duration}'s</tt>","|"]|add else empty end'
    echo "${line}"|jq -r 'if .event != "started" and .type != "suite" and .event == "failed"          then ["|","<span title=\"FAILED\"         >❌</span>|", "<span title=\"'${title}'\">'${name}'</span>","|","<tt title=\"'${duration_title}' seconds\">'${duration}'s</tt>","|"]|add else empty end'
    echo "${line}"|jq -r 'if .event != "started" and .type != "suite" and .event == "ignored"         then ["|","<span title=\"IGNORED\"        >🙈</span>|", "<span title=\"'${title}'\">'${name}'</span>","|","<tt title=\"'${duration_title}' seconds\">'${duration}'s</tt>","|"]|add else empty end'
    echo "${line}"|jq -r 'if .event != "started" and .type != "suite" and .event == "timeout"         then ["|","<span title=\"TIMEOUT\"        >⌛️</span>|", "<span title=\"'${title}'\">'${name}'</span>","|","<tt title=\"'${duration_title}' seconds\">'${duration}'s</tt>","|"]|add else empty end'
    echo "${line}"|jq -r 'if .event != "started" and .type != "suite" and .event == "allowed_failure" then ["|","<span title=\"ALLOWED_FAILURE\">🤷</span>|", "<span title=\"'${title}'\">'${name}'</span>","|","<tt title=\"'${duration_title}' seconds\">'${duration}'s</tt>","|"]|add else empty end'
done < ${cargo_test_results_file} >> results.md

export SUMMARY="$(cat results.md)"
SUMMARY="${SUMMARY//'%'/'%25'}"
SUMMARY="${SUMMARY//$'\n'/'%0A'}"
SUMMARY="${SUMMARY//$'\r'/'%0D'}"

echo "${SUMMARY}"
