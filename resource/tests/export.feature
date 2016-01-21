@export
Feature: Export

Background:
  When I set preference .citekeyFormat to [auth][year]
  And I set preference .jabrefGroups to false
  And I set preference .titleCase to true
  And I set preference .defaultDateParserLocale to en-GB
  And I set preference .bibtexURLs to 'note'

@test-cluster-2
@131
Scenario: Omit URL export when DOI present. #131
  When I import 3 references with 2 attachments from 'export/Omit URL export when DOI present. #131.json'
  And I set preference .DOIandURL to both
  And I set preference .jabrefGroups to true
  Then a library export using 'Better BibLaTeX' should match 'export/Omit URL export when DOI present. #131.default.bib'
  And I set preference .DOIandURL to doi
  Then a library export using 'Better BibLaTeX' should match 'export/Omit URL export when DOI present. #131.prefer-DOI.bib'
  And I set preference .DOIandURL to url
  Then a library export using 'Better BibLaTeX' should match 'export/Omit URL export when DOI present. #131.prefer-url.bib'

@test-cluster-3
@438
Scenario: Relax author name unpacking #438
  When I import 1 reference from 'export/Relax author name unpacking #438.json'
  And I set preference .relaxAuthors to true
  Then a library export using 'Better BibTeX' should match 'export/Relax author name unpacking #438.bib'

@test-cluster-2
@117
Scenario: Bibtex key regenerating issue when trashing items #117
  When I import 1 reference from 'export/Bibtex key regenerating issue when trashing items #117.json'
  And I select the first item where publicationTitle = 'Genetics'
  And I remove the selected item
  And I import 1 reference from 'export/Bibtex key regenerating issue when trashing items #117.json' as 'Second Import.json'
  Then a library export using 'Better BibLaTeX' should match 'export/Bibtex key regenerating issue when trashing items #117.bib'

@412 @test-cluster-1
Scenario: BibTeX URLs
  Given I import 1 reference from 'export/BibTeX; URL missing in bibtex for Book Section #412.json'
  And I set preference .bibtexURLs to 'off'
  Then a library export using 'Better BibTeX' should match 'export/BibTeX; URL missing in bibtex for Book Section #412.off.bib'
  When I set preference .bibtexURLs to 'note'
  Then a library export using 'Better BibTeX' should match 'export/BibTeX; URL missing in bibtex for Book Section #412.note.bib'
  When I set preference .bibtexURLs to 'url'
  Then a library export using 'Better BibTeX' should match 'export/BibTeX; URL missing in bibtex for Book Section #412.url.bib'

@cayw
Scenario: CAYW picker
  When I import 3 references from 'export/cayw.json'
  And I pick '6 The time it takes: temporalities of planning' for CAYW:
    | label | page |
    | locator | 1 |
  And I pick 'A bicycle made for two? The integration of scientific techniques into archaeological interpretation' for CAYW:
    | label | chapter |
    | locator | 1 |
  Then the picks for pandoc should be '[@bentley_academic_2011, p. 1; @pollard_bicycle_2007, ch. 1]'
  And the picks for mmd should be '[#bentley_academic_2011][][#pollard_bicycle_2007][]'
  And the picks for latex should be '\cite[1]{bentley_academic_2011}\cite[ch. 1]{pollard_bicycle_2007}'
  And the picks for scannable-cite should be '{|Abram, 2014|p. 1||zu:0:ITEMKEY}{|Pollard and Bray, 2007|ch. 1||zu:0:ITEMKEY}'

@test-cluster-2
@307
Scenario: thesis zotero entries always create  bibtex entries #307
  When I import 2 references from 'export/thesis zotero entries always create  bibtex entries #307.json'
  Then a library export using 'Better BibTeX' should match 'export/thesis zotero entries always create  bibtex entries #307.bibtex'
  And a library export using 'Better BibLaTeX' should match 'export/thesis zotero entries always create  bibtex entries #307.biblatex'

@402
Scenario: bibtex; url export does not survive underscores #402
  When I import 1 reference from 'export/bibtex; url export does not survive underscores #402.json'
  Then a library export using 'Better BibLaTeX' should match 'export/bibtex; url export does not survive underscores #402.biblatex'
  And a library export using 'Better BibTeX' should match 'export/bibtex; url export does not survive underscores #402.bibtex'

@test-cluster-2
@110
@111
@molasses
Scenario: two ISSN number are freezing browser #110 / Generating keys and export broken #111
  When I import 1 reference from 'export/two ISSN number are freezing browser #110.json'
  And I select the first item where publicationTitle = 'Genetics'
  And I set the citation key
  Then a library export using 'Better BibLaTeX' should match 'export/two ISSN number are freezing browser #110.bib'

@test-cluster-2
@85
Scenario: Square brackets in Publication field (85), and non-pinned keys must change when the pattern does
  When I import 1 references from 'export/Square brackets in Publication field (85).json'
  Then a library export using 'Better BibTeX' should match 'export/Square brackets in Publication field (85).bib'
  And I set preference .citekeyFormat to [year]-updated
  Then a library export using 'Better BibTeX' should match 'export/Square brackets in Publication field (85) after pattern change.bib'

@test-cluster-2
@86
Scenario: Include first name initial(s) in cite key generation pattern (86)
  When I import 1 reference from 'export/Include first name initial(s) in cite key generation pattern (86).json'
   And I set preference .citekeyFormat to [auth+initials][year]
  Then a library export using 'Better BibTeX' should match 'export/Include first name initial(s) in cite key generation pattern (86).bib'

@pandoc
@372
Scenario: BBT CSL JSON; Do not use shortTitle and journalAbbreviation #372
  When I import 1 reference from 'export/BBT CSL JSON; Do not use shortTitle and journalAbbreviation #372.json'
  Then a library export using 'Better CSL JSON' should match 'export/BBT CSL JSON; Do not use shortTitle and journalAbbreviation #372.csl.json'

@pandoc
@365
Scenario: Export of creator-type fields from embedded CSL variables #365
  When I import 6 references from 'export/Export of creator-type fields from embedded CSL variables #365.json'
  Then a library export using 'Better BibLaTeX' should match 'export/Export of creator-type fields from embedded CSL variables #365.bib'
  And a library export using 'Better CSL JSON' should match 'export/Export of creator-type fields from embedded CSL variables #365.csl.json'

@pandoc
Scenario: Date export to Better CSL-JSON #360
  When I import 6 references from 'export/Date export to Better CSL-JSON #360.json'
  And a library export using 'Better CSL JSON' should match 'export/Date export to Better CSL-JSON #360.csl.json'

@test-cluster-2
@pandoc @432
Scenario: Pandoc/LaTeX Citation Export
  When I import 1 reference with 1 attachment from 'export/Pandoc Citation.json'
  Then a library export using 'Pandoc Citation' should match 'export/Pandoc Citation.pandoc'
  And a library export using 'LaTeX Citation' should match 'export/Pandoc Citation.latex'
  And a library export using 'Better CSL JSON' should match 'export/Pandoc Citation.csl.json'
  And a library export using 'Better CSL YAML' should match 'export/Pandoc Citation.csl.yml'

@test-cluster-2
@journal-abbrev
Scenario: Journal abbreviations
  When I set preferences:
    | .citekeyFormat    | [authors][year][journal]          |
    | .autoAbbrev       | true                              |
    | .autoAbbrevStyle  | http://www.zotero.org/styles/cell |
    | .pinCitekeys      | on-export                         |
   And I import 1 reference with 1 attachment from 'export/Better BibTeX.029.json'
  Then the following library export should match 'export/Better BibTeX.029.bib':
    | translator             | Better BibTeX  |
    | useJournalAbbreviation | true           |

@test-cluster-2
@81
Scenario: Journal abbreviations exported in bibtex (81)
  When I set preferences:
    | .citekeyFormat          | [authors2][year][journal:nopunct] |
    | .autoAbbrev             | true                              |
    | .autoAbbrevStyle        | http://www.zotero.org/styles/cell |
    | .pinCitekeys            | on-export                         |
   And I import 1 reference from 'export/Journal abbreviations exported in bibtex (81).json'
  Then the following library export should match 'export/Journal abbreviations exported in bibtex (81).bib':
    | translator              | Better BibTeX  |
    | useJournalAbbreviation  | true           |

@other
Scenario Outline: BibLaTeX Export
  Given I import <references> references from 'export/<file>.json'
  Then a library export using 'Better BibTeX' should match 'export/<file>.bib'

  Examples:
     | file                                                                               | references |
     | preserve BibTeX Variables does not check for null values while escaping #337       | 1          |

@postscript
Scenario: Post script
  Given I import 3 references from 'export/Export web page to misc type with notes and howpublished custom fields #329.json'
  And I set preference .postscript to 'export/Export web page to misc type with notes and howpublished custom fields #329.js'
  Then a library export using 'Better BibTeX' should match 'export/Export web page to misc type with notes and howpublished custom fields #329.bib'

@test-cluster-0
@bbt
Scenario Outline: BibLaTeX Export
  Given I import <references> references from 'export/<file>.json'
  Then a library export using 'Better BibTeX' should match 'export/<file>.bib'

  Examples:
     | file                                                                               | references |
     | capital delta breaks .bib output #141                                              | 1          |
     | Better BibTeX.027                                                                  | 1          |
     | Better BibTeX.026                                                                  | 1          |
     | Underscores break capital-preservation #300                                        | 1          |
     | Export C as {v C}, not v{C} #152                                                   | 1          |
     | Better BibTeX.018                                                                  | 1          |
     | Numbers confuse capital-preservation #295                                          | 1          |
     | Empty bibtex clause in extra gobbles whatever follows #99                          | 1          |
     | Export of item to Better Bibtex fails for auth3_1 #98                              | 1          |

@test-cluster-0
@266 @286
Scenario: Diacritics stripped from keys regardless of ascii or fold filters #266
  Given I import 1 reference from 'export/Diacritics stripped from keys regardless of ascii or fold filters #266.json'
  Then a library export using 'Better BibLaTeX' should match 'export/Diacritics stripped from keys regardless of ascii or fold filters #266-fold.bib'
  When I set preference .citekeyFold to false
  Then a library export using 'Better BibLaTeX' should match 'export/Diacritics stripped from keys regardless of ascii or fold filters #266-nofold.bib'

@384
Scenario: Do not caps-protect name fields #384
  Given I import 40 references from 'export/Do not caps-protect name fields #384.json'
  Then a library export using 'Better BibLaTeX' should match 'export/Do not caps-protect name fields #384.biblatex'
  And a library export using 'Better BibTeX' should match 'export/Do not caps-protect name fields #384.bibtex'

@383
Scenario: Capitalize all title-fields for language en #383
  Given I import 8 references from 'export/Capitalize all title-fields for language en #383.json'
  Then a library export using 'Better BibLaTeX' should match 'export/Capitalize all title-fields for language en #383.bib'

@411 @test-cluster-1
Scenario: Sorting and optional particle handling #411
  Given I import 2 references from 'export/Sorting and optional particle handling #411.json'
  And I set preference .parseParticles to true
  Then a library export using 'Better BibLaTeX' should match 'export/Sorting and optional particle handling #411.on.bib'
  When I set preference .parseParticles to false
  Then a library export using 'Better BibLaTeX' should match 'export/Sorting and optional particle handling #411.off.bib'

@test-cluster-0
@bblt
@bblt-0
@127
@201
@219
@253
@268
@288
@294
@302
@308
@309
@310
@326
@327
@351
@376
@389
Scenario Outline: BibLaTeX Export
  Given I import <references> references from 'export/<file>.json'
  Then a library export using 'Better BibLaTeX' should match 'export/<file>.bib'

  Examples:
     | file                                                                                           | references  |
     | Book sections have book title for journal in citekey #409                                      | 1           |
     | Colon in bibtex key #405                                                                       | 1           |
     | condense in cite key format not working #308                                                   | 1           |
     | Better BibLaTeX.009                                                                            | 2           |
     | Better BibLaTeX.003                                                                            | 2           |
     | Better BibLaTeX.005                                                                            | 1           |
     | Better BibLaTeX.006                                                                            | 1           |
     | Fields in Extra should override defaults                                                       | 1           |
     | BibTeX variable support for journal titles. #309                                               | 1           |
     | Better BibLaTeX.004                                                                            | 1           |
     | Oriental dates trip up date parser #389                                                        | 1           |
     | Better BibLaTeX.007                                                                            | 1           |
     | Text that legally contains the text of HTML entities such as &nbsp; triggers an overzealous decoding second-guesser #253 | 1 |
     | Non-ascii in dates is not matched by date parser #376                                          | 1           |
     | @jurisdiction; map court,authority to institution #326                                         | 1           |
     | @legislation; map code,container-title to journaltitle #327                                    | 1           |
     | BraceBalancer                                                                                  | 1           |
     | BibLaTeX; export CSL override 'issued' to date or year #351                                    | 1           |
     | auth leaves punctuation in citation key #310                                                   | 1           |
     | Spaces not stripped from citation keys #294                                                    | 1           |
     | Book converted to mvbook #288                                                                  | 1           |
     | Colon not allowed in citation key format #268                                                  | 1           |
     | Export mapping for reporter field #219                                                         | 1           |
     | Export error for items without publicationTitle and Preserve BibTeX variables enabled #201     | 1           |
     | Be robust against misconfigured journal abbreviator #127                                       | 1           |
     | Better BibLaTeX.001                                                                            | 1           |
     | Better BibLaTeX.002                                                                            | 2           |
     | csquotes #302                                                                                  | 2           |

@test-cluster-1
@bblt
@bblt-1
Scenario Outline: BibLaTeX Export
  Given I import <references> references from 'export/<file>.json'
  Then a library export using 'Better BibLaTeX' should match 'export/<file>.bib'

  Examples:
     | file                                                                               | references  |
     | biblatex export of phdthesis does not case-protect -type- #435                     | 1           |
     | Export Forthcoming as Forthcoming                                                  | 1           |
     | CSL variables only recognized when in lowercase #408                               | 1           |
     | date and year are switched #406                                                    | 4           |
     | Malformed HTML                                                                     | 1           |
     | Capitalisation in techreport titles #160                                           | 1           |
     | Better BibLaTeX.019                                                                | 1           |
     | Exporting of single-field author lacks braces #130                                 | 1           |
     | Better BibLaTeX.011                                                                | 1           |
     | Better BibLaTeX.stable-keys                                                        | 6           |
     | Do not caps-protect literal lists #391                                             | 3           |
     | biblatex; Language tag xx is exported, xx-XX is not #380                           | 1           |
     | CSL title, volume-title, container-title=BL title, booktitle, maintitle #381       | 2           |
     | Better BibTeX does not use biblatex fields eprint and eprinttype #170              | 1           |
     | typo stature-statute (zotero item type) #284                                       | 1           |
     | Normalize date ranges in citekeys #356                                             | 3           |
     | Shortjournal does not get exported to biblatex format #102 - biblatexcitekey #105  | 1           |
     | Math parts in title #113                                                           | 1           |
     | Better BibLaTeX.021                                                                | 1           |
     | remove the field if the override is empty #303                                     | 1           |
     | Extra semicolon in biblatexadata causes export failure #133                        | 2           |
     | map csl-json variables #293                                                        | 2           |
     | markup small-caps, superscript, italics #301                                       | 2           |
     | don't escape entry key fields for #296                                             | 1           |
     | bookSection is always converted to @inbook, never @incollection #282               | 1           |
     | referencetype= does not work #278                                                  | 1           |
     | Ignore HTML tags when generating citation key #264                                 | 1           |
     | Better BibLaTeX.016                                                                | 1           |
     | BBT export of square brackets in date #245 -- xref should not be escaped #246      | 3           |
     | Better BibLaTeX.010                                                                | 1           |
     | Better BibLaTeX.012                                                                | 1           |
     | Better BibLaTeX.013                                                                | 1           |
     | Better BibLaTeX.014                                                                | 1           |
     | Better BibLaTeX.015                                                                | 1           |
     | Better BibLaTeX.017                                                                | 1           |
     | Better BibLaTeX.020                                                                | 1           |
     | Better BibLaTeX.022                                                                | 1           |
     | Better BibLaTeX.023                                                                | 1           |
     | DOI with underscores in extra field #108                                           | 1           |
     | Export Newspaper Article misses section field #132                                 | 1           |
     | German Umlaut separated by brackets #146                                           | 1           |
     | Hang on non-file attachment export #112 - URL export broken #114                   | 2           |
     | HTML Fragment separator escaped in url #140 #147                                   | 1           |
     | References with multiple notes fail to export #174                                 | 1           |
     | underscores in URL fields should not be escaped #104                               | 1           |
     | Allow explicit field override                                                      | 1           |

@test-cluster-0
@ae
Scenario: auto-export
  Given I import 3 references with 2 attachments from 'export/autoexport.json'
  Then a library export using 'Better BibLaTeX' should match 'export/autoexport.before.bib'
  And I export the library to 'tmp/autoexport.bib':
    | translator    | Better BibLaTeX |
    | Keep updated  | true            |
  When I select the first item where publisher = 'IEEE'
  And I remove the selected item
  And I wait 5 seconds
  Then 'tmp/autoexport.bib' should match 'export/autoexport.after.bib'

#@163
#Scenario: Preserve Bib variable names #163
#  When I import 1 reference from 'export/Preserve Bib variable names #163.json'
#  Then a library export using 'Better BibLaTeX' should match 'export/Preserve Bib variable names #163.bib'

@313
Scenario: (non-)dropping particle handling #313
  When I import 53 references from 'export/(non-)dropping particle handling #313.json'
  Then a library export using 'Better BibLaTeX' should match 'export/(non-)dropping particle handling #313.bib'
