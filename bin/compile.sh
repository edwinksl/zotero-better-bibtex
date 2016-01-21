#!/bin/bash

set -e

echo "=========================================================="
echo "Compiling $1"
echo "=========================================================="
echo
echo

MYTMPDIR=`mktemp -d`
MWE="$MYTMPDIR/mwe.tex"
trap "rm -rf $MYTMPDIR" EXIT

cat << EOTEX > "$MWE"
\\documentclass{article}

\\usepackage{filecontents}
\\begin{filecontents}{\jobname.bib}
EOTEX

cat "$1" >> "$MWE"

cat << EOTEX >> "$MWE"
\end{filecontents}

\begin{document}
EOTEX

grep '^@' "$1" | sed -e 's/.*{//' | sed -e 's/,$//' | awk '{ print "\\cite{" $1 "}" }' >> "$MWE"

cat << EOTEX >> "$MWE"
\bibliographystyle{alpha}
\bibliography{\jobname}

\end{document}
EOTEX

cd "$MYTMPDIR"
latexmk -silent mwe.tex
#rubber -q mwe.tex
