#$ delay 10

cat ./hello_world.sh
#$ expect \$

asciinema-automation --asciinema-arguments "--overwrite -c 'env -i PS1=\"$ \" bash --noprofile --norc'" ./hello_world.sh ./test.cast
#$ expect \$

asciinema play ./test.cast
#$ expect exit
#$ expect \$
