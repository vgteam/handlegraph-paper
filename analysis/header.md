---
papersize: a4
documentclass: extarticle
fontsize: 8pt
header-includes:
    - \usepackage{multicol}
    - \usepackage[landscape,paperheight=12in,paperwidth=8in,margin=1in]{geometry}
    - \newcommand{\hideFromPandoc}[1]{#1}
    - \hideFromPandoc{
        \let\Begin\begin
        \let\End\end
      }

...


