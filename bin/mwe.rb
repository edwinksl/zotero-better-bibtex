#!/usr/bin/env ruby

BULK=[
  'Really Big whopping library.biblatex',
  'Bulk performance test.biblatex',
  'Bulk performance test.stock.biblatex',
].include?File.basename(ARGV[0])

BIB=ARGV[0]

open('mwe.tex', 'w') {|mwe|
  mwe.puts("""
    \\documentclass{article}
    \\usepackage{filecontents}
    \\begin{filecontents}{\jobname.bib}
  """)

  if BULK
    mwe.puts("""
      @inproceedings{bulk,
        author = {Bulk},
        booktitle = {Bulk}
      }
    """)
  else
    mwe.puts(open(BIB).read)
  end

  mwe.puts("\\end{filecontents}")

  if File.extname(BIB) == '.biblatex'
    mwe.puts("""
      \\usepackage[backend=biber,style=authoryear-icomp,natbib=true,url=false,doi=true,eprint=false]{biblatex}
      \\addbibresource{\\jobname}
    """)
  else
    mwe.puts("""
      \\usepackage{url}
    """)
  end

  mwe.puts("\\begin{document}")

  if BULK
    mwe.puts("\\cite{bulk}")
  else
    IO.readlines(BIB).each{|line|
      next unless line.strip =~ /^@.*{(.*),$/
      mwe.puts("\\cite{#{$1}}")
    }
  end

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
