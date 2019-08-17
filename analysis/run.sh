#!/bin/bash

rm -f *txt *pdf && ./run.R && pdfjoin -o bdsg.prof.pdf $(ls bdsg*.pdf -rt1 ) && (cat header.md; echo '\Begin{multicols}{2}'; ( ls -rt *txt | xargs head -1000 | sed 's/==>/```\n\\pagebreak\n\n#/g' | sed 's/<==/\n\n```/g'  ; echo '```' ) | tail -n+3 | awk '{ print $0 } ' ; echo '\End{multicols}') >bdsg.models.md && pandoc -o bdsg.models.pdf bdsg.models.md && pdfjoin -o bdsg.prof.prez.pdf bdsg.prof.pdf bdsg.models.pdf
