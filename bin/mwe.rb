#!/usr/bin/env ruby

BIB=ARGV[0]

open('mwe.tex', 'w') {|mwe|
  mwe.puts("""
    \\documentclass{article}
    \\usepackage{filecontents}
    \\begin{filecontents}{\jobname.bib}
  """)

  mwe.puts(open(BIB).read)

  mwe.puts("\\end{filecontents}")

  if File.extname(BIB) == '.biblatex'
    mwe.puts("""
      \\usepackage[backend=biber,style=authoryear-icomp,natbib=true,url=false,doi=true,eprint=false]{biblatex}
      \\addbibresource{\\jobname}
    """)
  end

  mwe.puts("\\begin{document}")

  IO.readlines(BIB).each{|line|
    next unless line.strip =~ /^@.*{(.*),$/
    mwe.puts("\\cite{#{$1}}")
  }

  if File.extname(BIB) == '.biblatex'
    mwe.puts("\\printbibliography")
  else
    mwe.puts("""
      \\bibliographystyle{alpha}
      \\bibliography{\jobname}
    """)
  end

  mwe.puts("\\end{document}")
}
