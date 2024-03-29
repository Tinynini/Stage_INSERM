#!/bin/bash

cluster='/home/ninon.robin/Projet-Cluster/Output/cluster_fast_gene_0.95.txt'
cat ${cluster} | grep -E -v '^C' > /home/ninon.robin/alt_bash_script/data/clust.txt
  
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

#### Donnees de test ####

res_ninon_path="/home/ninon.robin/alt_bash_script/data/species_test/"
find ${res_ninon_path} -name "*.tsv" > /home/ninon.robin/alt_bash_script/data/species_test_ninon.txt
cat /home/ninon.robin/alt_bash_script/data/species_test_ninon.txt | sort -f -t '/' -k 6 > /home/ninon.robin/alt_bash_script/data/sort_species_test_ninon.txt

#### Vraies donnees ####

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

du -a $(cat /home/ninon.robin/alt_bash_script/data/full_species_ninon.txt) | sort -r -g > /home/ninon.robin/alt_bash_script/data/sort_DU.txt

cat alt_bash_script/data/sort_DU.txt | sed -n '1p' | cut -f 2 > alt_bash_script/data/Parsed_species/E.coli.txt
cat alt_bash_script/data/sort_DU.txt | sed -n '2p' | cut -f 2 > alt_bash_script/data/Parsed_species/Salm.enter.txt
cat alt_bash_script/data/sort_DU.txt | sed -n '3p' | cut -f 2 > alt_bash_script/data/Parsed_species/Klebs.pneumo.txt
cat alt_bash_script/data/sort_DU.txt | sed -n '4,11p' | cut -f 2 > alt_bash_script/data/Parsed_species/1G.txt
cat alt_bash_script/data/sort_DU.txt | sed -n '12,21p' | cut -f 2 > alt_bash_script/data/Parsed_species/100M-1.txt
cat alt_bash_script/data/sort_DU.txt | sed -n '22,51p' | cut -f 2 > alt_bash_script/data/Parsed_species/100M-2.txt
cat alt_bash_script/data/sort_DU.txt | sed -n '52,221p' | cut -f 2 > alt_bash_script/data/Parsed_species/10M.txt
cat alt_bash_script/data/sort_DU.txt | sed -n '222,780p' | cut -f 2 > alt_bash_script/data/Parsed_species/1M.txt
cat alt_bash_script/data/sort_DU.txt | sed -n '781,3133p' | cut -f 2 > alt_bash_script/data/Parsed_species/100K.txt
cat alt_bash_script/data/sort_DU.txt | sed -n '3134,6284p' | cut -f 2 > alt_bash_script/data/Parsed_species/10K.txt
cat alt_bash_script/data/sort_DU.txt | sed -n '6285,11822p' | cut -f 2 > alt_bash_script/data/Parsed_species/1K.txt
