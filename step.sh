#!/usr/bin/env bash

set -e

git fetch --tags

tags="$(git tag | grep "$project_prefix[0-9]{1,5}_.*" -E -o || true)"

tags=($(echo "$tags" | tr ' ' '\n'))

epics=""

if (( ${#tags[*]} > 0 ))
then
last_index=0
for (( i=0 ; i<${#tags[*]} ; ++i ))
do
tag_elements=($(echo "${tags[$i]}" | tr '_' '\n'))

tags_list[$last_index]="${tag_elements[0]}"

tag_title=""

for (( j=1 ; j<${#tag_elements[*]} ; ++j ))
do
tag_title+="${tag_elements[$j]}"

if (( j < ${#tag_elements[*]} - 1 ))
then
tag_title+=" "
fi
done

last_index=$((last_index + 1))
tags_list[$last_index]="$tag_title"

last_index=$((last_index + 1))
done

for (( i=0 ; i<${#tags_list[*]} ; i+=2 ))
do

epics+="${tags_list[$((i + 1))]}"$'\n'$'\n'$'\t'"$backlog_default_url${tags_list[$i]}"

if (( i < ${#tags_list[*]} - 1 ))
then
epics+=$'\n'$'\n'
fi

done

fi

envman add --key EPICS_FROM_TAGS --value "$epics"

echo "Epics featured:"
echo ""
envman run bash -c 'echo "$EPICS_FROM_TAGS"'

ESCAPED_URL=$(echo ${backlog_default_url} | sed -e "s#/#\\\/#g")

git log --pretty=format:"%s" | grep "$project_prefix[0-9]{1,5}" -o -E | sort -u -r --version-sort | sed -e 's/^/'${ESCAPED_URL}'/' | envman add --key FEATURES_FROM_COMMITS

echo "Features:"
echo ""
envman run bash -c 'echo "$FEATURES_FROM_COMMITS"'
