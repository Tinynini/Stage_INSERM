#!/bin/bash

./generater_liste_data.sh

liste_arg="/home/ninon.robin/2023_recup/data/order_liste_arg.txt"
liste_gff="/home/ninon.robin/2023_recup/data/order_liste_gff.txt"

n_jump=2

## Methode sans tableau pour les gff --> ~4h donc un peu long
for ARG in $(cat ${liste_arg})
do 
    gff=$(grep ${ARG%_*} ${liste_gff})
    cat ${gff} | grep -C ${n_jump} ${ARG} | egrep ID=GCF_[0-9]*_[0-9]*_gene
done > /home/ninon.robin/2023_recup/output/liste_av_ap_gene.txt
## Fin de methode

## Methode avec tableau pour les gff --> -3h donc ca va grave !!
declare -A table_gff

for line in $(cat ${liste_gff}) 
do 
    key=$(basename ${line})
    key=${key%.gff};
    table_gff[${key}]=${line}
done 

echo '2nd partie'

for ARG in $(cat ${liste_arg}) 
do 
    curr_key=$(echo ${ARG%_*}) 
    gff=$(echo ${table_gff[${curr_key}]})
    contig=$(cat ${gff} | grep ${ARG} | egrep ID=GCF_[0-9]*_[0-9]*_gene | awk '{print gensub(/(.*)_([0-9]*$)/, "\\1\\_\\2", "g", $1)}')
    cat ${gff} | grep -C ${n_jump} ${ARG} | egrep ID=GCF_[0-9]*_[0-9]*_gene | grep ${contig} | grep -v ${ARG}
done > /home/ninon.robin/2023_recup/output/liste_av_ap_gene.txt 
## Fin de methode

## Methode qui marche et c est tres rapide
gene_av_ap="/home/ninon.robin/2023_recup/output/liste_av_ap_gene.txt"
IFS=$'\n\n'

cat ${gene_av_ap} | awk '{print gensub(/ID=(.*)_(gene;.*)/, "\\1", "g", $9)}' > /home/ninon.robin/2023_recup/output/liste_id.txt
cat /home/ninon.robin/2023_recup/output/liste_id.txt | sort | uniq > /home/ninon.robin/2023_recup/output/order_liste_id.txt 

liste_id="/home/ninon.robin/2023_recup/output/order_liste_id.txt"

cat ${liste_id} | awk '{print gensub(/(.*)_(.*)/, "\\1", "g", $0)}' > /home/ninon.robin/2023_recup/output/liste_seq.txt
cat /home/ninon.robin/2023_recup/output/liste_seq.txt | sort | uniq > /home/ninon.robin/2023_recup/output/order_liste_seq.txt 
## Fin de methode
