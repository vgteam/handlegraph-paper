#!/bin/bash

rm -f *txt *pdf && ./run.R && pdfunite $(ls bdsg*.pdf -rt1 ) bdsg.prof.pdf && (cat header.md; echo '\Begin{multicols}{2}'; ( ls -rt *txt | xargs head -1000 | sed 's/==>/```\n\\pagebreak\n\n#/g' | sed 's/<==/\n\n```/g'  ; echo '```' ) | tail -n+3 | awk '{ print $0 } ' ; echo '\End{multicols}') >bdsg.models.md && pandoc -o bdsg.models.pdf bdsg.models.md && pdfunite bdsg.prof.pdf bdsg.models.pdf bdsg.prof.prez.pdf 
