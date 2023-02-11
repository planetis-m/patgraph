# Package

version       = "0.2.0"
author        = "Antonis"
description   = "graph data structure library"
license       = "MIT"

# Dependencies

requires "nim >= 1.0.9"

import os

const
  ProjectUrl = "https://github.com/planetis-m/patgraph"
  PkgDir = thisDir().quoteShell
  DocsDir = PkgDir / "docs"

task docs, "Generate documentation":
  # https://nim-lang.github.io/Nim/docgen.html
  withDir(PkgDir):
    let tmp = "patgraph"
    let doc = DocsDir / (tmp & ".html")
    let src = tmp & ".nim"
    # Generate the docs for {src}
    exec("nim doc --verbosity:0 --git.url:" & ProjectUrl &
        " --git.devel:master --git.commit:master --out:" & doc & " " & src)
