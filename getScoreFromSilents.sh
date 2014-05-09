#!/bin/sh
sf=${1}
grep '^SCORE' $sf >score.sc
head -n 1 score.sc >head.out
sed '/^SCORE:     score/d' score.sc >temp.sc
cat head.out temp.sc >score.sc
rm temp.sc head.out

