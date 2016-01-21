#!/usr/bin/env ruby

BULK=[
  'Really Big whopping library.biblatex',
  'Bulk performance test.biblatex',
  'Bulk performance test.stock.biblatex',
].include?File.basename(ARGV[0])

BIB=ARGV[0]
CITE=File.extname(BIB) == '.biblatex' ? 'citet' : 'cite'

if File.extname(BIB) == '.biblatex'
  PACKAGES=[
    '\\usepackage[utf8]{inputenc}',
    '\\usepackage[backend=biber,style=authoryear-icomp,natbib=true,url=false,doi=true,eprint=false]{biblatex}'
  ]
else
  PACKAGES=[
    '\\usepackage{url}'
  ]
end

open('mwe.tex', 'w') {|mwe|
  mwe.puts("\\documentclass{article}")
  mwe.puts("\\usepackage{filecontents}")
  PACKAGES.each{|pkg| mwe.puts(pkg) }

  mwe.puts("\\begin{filecontents*}{\\jobname.bib}")
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
  mwe.puts("\\end{filecontents*}")

  mwe.puts("\\addbibresource{\\jobname}") if File.extname(BIB) == '.biblatex'

  mwe.puts("\\begin{document}")

  if BULK
    mwe.puts("\\#{CITE}{bulk}")
  else
    IO.readlines(BIB).each{|line|
      next unless line.strip =~ /^@.*{(.*),$/
      mwe.puts("\\#{CITE}{#{$1}}")
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
