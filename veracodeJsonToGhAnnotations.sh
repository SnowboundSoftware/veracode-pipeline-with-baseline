#!/bin/bash
REPORTFILE='results.json'
BASEDIR='src/'

for row in $(cat "${REPORTFILE}" | jq -r '.findings[] | @base64'); do
    _jq() {
     echo ${row} | base64 --decode | jq -r ${1}
    }
    TITLE=$(_jq '.title')
    ISSUE_TYPE=$(_jq '.issue_type')
    DISPLAY_TEXT=$(_jq '.display_text' | sed 's/<span>//g' | sed 's/<\/span>//g' | sed 's/<a href="//g' | sed 's/">.*<\/a>//g' | sed 's/  / /g')

    FILE=$(_jq '.files.source_file.file')
    LINE=$(_jq '.files.source_file.line')

    # Debug
    #echo Title: $TITLE
    #echo Issue Type: $ISSUE_TYPE
    #echo Display Text: $DISPLAY_TEXT
    #echo File@Line: $FILE@$LINE
    #echo

    # GitHub will parse this output
    echo "::warning title=$ISSUE_TYPE,file=$BASEDIR$FILE,line=$LINE::$DISPLAY_TEXT"
done
