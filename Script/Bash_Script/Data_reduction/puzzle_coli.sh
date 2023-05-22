#!/bin/bash
 
#./data_parser.sh

#### Avec les vraies donnees ####

species_ninon='/home/ninon.robin/alt_bash_script/data/Parsed_species/E.coli.txt'
cluster='/home/ninon.robin/alt_bash_script/data/clusters.txt'

#### Main matrice ####

species=$(cat ${species_ninon} | sed 's/^\/.*\/.*\/.*\//,/g' | sed 's/.tsv//g') 
echo -n -e 'SPECIES'${species}\\\n | sed 's/ //g' > /home/ninon.robin/alt_bash_script/output/Puzzle_matrix/Coli_species.tsv

centroid=$(cat ${cluster} | cut -f 10 | sort | uniq)

for centro in $(echo ${centroid})
do
    echo ${centro} >> /home/ninon.robin/alt_bash_script/output/Puzzle_matrix/centro.tsv
    query=$(cat ${cluster} | grep ${centro} | cut -f 9 | sort | uniq)
    query=$(echo ${query} | sed 's/ /|/g')

    for path in $(cat ${species_ninon})  
    do 
        match=$(cut -f 1 ${path} | grep -E -c ${query})

        if [ ${match} != 0 ]
        then 
            match=1
        fi

        echo -n ,${match} >> /home/ninon.robin/alt_bash_script/output/Puzzle_matrix/Coli_share.tsv
    done 

    printf \\\n >> /home/ninon.robin/alt_bash_script/output/Puzzle_matrix/Coli_share.tsv
done 