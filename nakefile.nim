import nake, std/strformat

task "docs", "Generate documentation":
  # https://nim-lang.github.io/Nim/docgen.html
  let
    src = "patgraph.nim"
    dir = "docs/"
    doc = dir / src.changeFileExt(".html")
    url = "https://github.com/planetis-m/patgraph"
  if doc.needsRefresh(src):
    echo "Generating the docs..."
    direShell(nimExe,
        &"doc --verbosity:0 --git.url:{url} --git.devel:master --git.commit:master --out:{dir} {src}")
  else:
    echo "Skipped generating the docs."

task "test", "Run the tests":
  for f in walkFiles("tests/t*.nim"):
    direShell(nimExe, &"c -r --verbosity:0 --path:../ {f}") # --forceBuild
