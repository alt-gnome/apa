#!/bin/bash
# Should run from project root dir

touch ./po/unsort-POTFILES.in

find ./src -iname "*.vala" -type f -exec grep -lrE '_\(|C_|ngettext' {} + | while read file; do echo "${file#./}" >> ./po/unsort-POTFILES.in; done

cat ./po/unsort-POTFILES.in | sort | uniq > ./po/POTFILES.in

rm ./po/unsort-POTFILES.in
