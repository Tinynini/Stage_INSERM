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

<< 'comment'
centro='/home/ninon.robin/alt_bash_script/output/centro.tsv'

Coli_species='/home/ninon.robin/alt_bash_script/output/Coli_species.tsv'
Salm_species='/home/ninon.robin/alt_bash_script/output/Salm.enter_species.tsv'
Klebs_species='/home/ninon.robin/alt_bash_script/output/Klebs.pneumo_species.tsv'
G_species='/home/ninon.robin/alt_bash_script/output/1G_species.tsv'
M_species='/home/ninon.robin/alt_bash_script/output/100M-1K_species.tsv'
Coli_share='/home/ninon.robin/alt_bash_script/output/Coli_share.tsv'
Salm_share='/home/ninon.robin/alt_bash_script/output/Salm.enter_share.tsv'
Klebs_share='/home/ninon.robin/alt_bash_script/output/Klebs.pneumo_share.tsv'
G_share='/home/ninon.robin/alt_bash_script/output/1G_share.tsv'
M_share='/home/ninon.robin/alt_bash_script/output/100M-1K_share.tsv'

past ${Coli_species} ${Salm_species} ${Klebs_species} ${G_species} ${M_species}  > /home/ninon.robin/alt_bash_script/output/matrix.tsv
paste ${centro} ${Coli_share} ${Salm_share} ${Klebs_share} ${G_share} ${M_share} | sed 's/\t//g' >> /home/ninon.robin/alt_bash_script/output/matrix.tsv
comment