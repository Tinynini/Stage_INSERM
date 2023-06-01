#!/bin/bash
 
#./data_parser.sh

#### Avec les vraies donnees ####

species_ninon=${1}
cluster='/home/ninon.robin/alt_bash_script/data/clusters.txt'

#### Main matrice ####

species=$(cat ${species_ninon} | sed 's/^\/.*\/.*\/.*\//,/g' | sed 's/.tsv//g') 
echo -n -e ${species}\\\n | sed 's/ //g' > ${2}

centroid=$(cat ${cluster} | cut -f 10 | sort | uniq)

for centro in $(echo ${centroid})
do
    query=$(cat ${cluster} | grep ${centro} | cut -f 9 | sort | uniq)
    query=$(echo ${query} | sed 's/ /|/g')

    for path in $(cat ${species_ninon})  
    do 
        match=$(cut -f 1 ${path} | grep -E -c ${query})

        if [ ${match} != 0 ]
        then 
            match=1
            echo "match for ${centro} Species $(basename ${path})"
        fi

        echo -n ,${match} >> ${3}
    done 

    printf \\\n >> ${3}
done 
