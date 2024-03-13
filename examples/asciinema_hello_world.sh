#$ delay 50

asciinema rec demos/temp_test.cast \
    --overwrite \
    -c 'env -i PS1=$ bash --noprofile --norc' \
    -q
#$ expect \$

echo "Hello World"
#$ expect \$

# control instructions send control command, for example ctrl-d
#$ sendcontrol d

#$ expect \$

asciinema play demos/temp_test.cast
#$ expect exit
#$ expect \$
