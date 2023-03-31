#!/bin/bash -x

ROOT=$(git rev-parse --show-toplevel)
TMPD=$(mktemp -d /tmp/latexdiff.XXXXXXXXXX)
HERE=$(realpath --relative-to=$ROOT $(pwd))
FILES=$(find . -maxdepth 1 -name '*.tex' | grep -v 'relwk' | grep -v 'cmds'  | grep -v 'pkgs' | grep -v 'warning' | grep -v 'hdr' | sed 's/\.tex//g' | sed 's/\.\///g' | awk '{printf("%s ", $1)}')

mkdir -p $TMPD

OLD_REPO=$TMPD/old
NEW_REPO=$TMPD/new

git clone $ROOT $OLD_REPO
# git clone $ROOT $NEW_REPO
cp -r $ROOT $NEW_REPO

cd $OLD_REPO
git checkout $1

NEWD=$NEW_REPO/$HERE
OLDD=$OLD_REPO/$HERE

cd $OLDD
make
cd $NEWD
make
# latexdiff --flatten --math-markup=0 --exclude-textcmd="PP,sys,cc,subsection,section" --disable-citation-markup p.tex $NEWD/p.tex > diff.tex

for f in $FILES
do
  latexdiff --math-markup=0 --exclude-textcmd="PP,cc,subsection,section" --disable-citation-markup $OLDD/$f.tex $f.tex > temp.tex
  mv temp.tex $f.tex
done

# make MAIN=diff
make
cp -f p.pdf $ROOT/$HERE/diff.pdf
