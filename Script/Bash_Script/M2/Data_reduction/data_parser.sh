#!/bin/bash

#cluster='/home/ninon.robin/Projet-Cluster/Output/cluster_fast_gene_0.95.txt'
#cat ${cluster} | grep -E -v '^C' > /home/ninon.robin/alt_bash_script/data/clust.txt
  
IFS=$'\n'    
for line in $(cat /home/ninon.robin/alt_bash_script/data/clust.txt)  
do 
    if [ -n "$(echo ${line} | grep -E '^S')" ]
    then 
        start=$(echo ${line} | cut -f -9)
        echo -n -e ${start}\\\t >> /home/ninon.robin/alt_bash_script/data/clusters.txt
        echo ${line} | cut -f 9 >> /home/ninon.robin/alt_bash_script/data/clusters.txt
    else
        echo ${line} >> /home/ninon.robin/alt_bash_script/data/clusters.txt
    fi
done 

#### Avec les vraies donnees ####

res_ninon_path="/home/ninon.robin/diamond_ninon/"
find ${res_ninon_path} -name "*.tsv" > /home/ninon.robin/alt_bash_script/data/species_ninon.txt
cat /home/ninon.robin/alt_bash_script/data/species_ninon.txt | sort -f -t '/' -k 4 > /home/ninon.robin/alt_bash_script/data/full_species_ninon.txt
full_species='/home/ninon.robin/alt_bash_script/data/full_species_ninon.txt'

while read path 
do 
    if [ -n "$(head -n 1 ${path})" ]
    then 
        echo ${path}
    fi
done < "${full_species}" > /home/ninon.robin/alt_bash_script/data/sort_species_ninon.txt

#### Avec les donnees de test ####

res_ninon_path="/home/ninon.robin/alt_bash_script/data/species_test/"
find ${res_ninon_path} -name "*.tsv" > /home/ninon.robin/alt_bash_script/data/species_test_ninon.txt
cat /home/ninon.robin/alt_bash_script/data/species_test_ninon.txt | sort -f -t '/' -k 6 > /home/ninon.robin/alt_bash_script/data/sort_species_test_ninon.txt
