#!/bin/bash

./generater_liste_data.sh

liste_arg="../data/order_liste_arg.txt"
liste_gff="../data/order_liste_gff.txt"

n_jump=2

## Methode sans tableau pour les gff --> ~4h donc un peu long
#time $( for ARG in $(head -n 10 ${liste_arg}); do gff=$(grep ${ARG%_*} ${liste_gff}); cat ${gff} | grep -C ${n_jump} ${ARG} | egrep ID=GCF_[0-9]*_[0-9]*_gene; done > ../output/list_avap_gene.txt) 
## Fin de methode

## Methode avec tableau pour les gff --> -3h donc ca va grave !!
declare -A table_gff

for line in $(head -n 4644 ${liste_gff}) 
do 
    key=$(basename ${line})
    key=${key%.gff}; 
    table_gff[${key}]=${line}
done 

echo '2nd partie'

time $( for ARG in $(head -n 10000 ${liste_arg}); do curr_key=$(echo ${ARG%_*}); gff=$(echo ${table_gff[${curr_key}]}); contig=$(cat ${gff} | grep ${ARG} | egrep ID=GCF_[0-9]*_[0-9]*_gene | awk '{print gensub(/(.*)_([0-9]*$)/, "\\1\\_\\2", "g", $1)}'); cat ${gff} | grep -C ${n_jump} ${ARG} | egrep ID=GCF_[0-9]*_[0-9]*_gene | grep ${contig} | grep -v ${ARG}; done > ../output/list_avap_gene.txt)
## Fin de methode 
exit
## Methode qui marche et c est tres rapide
gene_av_ap="/home/ninon.robin/2023_recup/output/liste_av_ap_gene.txt"
IFS=$'\n\n'

time $(head -n 10 ${gene_av_ap} | awk '{print gensub(/ID=(.*)_(gene;.*)/, "\\1", "g", $9)}' > ../output/liste_id.txt)
cat ../output/liste_id.txt | sort | uniq > ../output/order_liste_id.txt 

liste_id="../output/order_liste_id.txt"

time $(head -n 10 ${liste_id} | awk '{print gensub(/(.*)_(.*)/, "\\1", "g", $0)}' > ../output/liste_seq.txt) 
cat ../output/liste_seq.txt | sort | uniq > ../output/order_liste_seq.txt 
## Fin de methode

liste_id="../output/order_liste_id.txt"
liste_seq="../output/order_liste_seq.txt"
liste_ffn="../data/order_liste_ffn.txt"

## Methode sans tableau pour les ffn --> +3h30 donc ca va !
time $( for seq in $(head -n 10 ${liste_seq}); do ffn=$(grep ${seq} ${liste_ffn}); ids=$(cat ${liste_id} | grep ${seq} | awk '{print $0"|"}' | tr -d '\n'); ids=${ids%?}; cat ${ffn} | sed 's/^>\(.*\)$/######>\1######/g' | tr -d '\n' | sed 's/######/\n/g' | grep -E -A1 ${ids} | sed 's/^--//g' | egrep -v ^$; done > ../output/listeseqffn.ffn)
## Fin de methode

## Methode avec tableau pour les ffn --> -3h30 donc encore mieux !
declare -A table_ffn

for line in $(head -n 15 ${liste_ffn})
do 
    key=$(basename ${line})
    key=${key%.ffn}
    table_ffn[${key}]=${line}
done 

echo '2nd partie'

time $( for seq in $(head -n 10 ${liste_seq}); do curr_key=$(echo ${seq}); ffn=$(echo ${table_ffn[${curr_key}]}); ids=$(cat ${liste_id} | grep ${seq} | awk '{print $0"|"}' | tr -d '\n'); ids=${ids%?}; cat ${ffn} | sed 's/^>\(.*\)$/######>\1######/g' | tr -d '\n' | sed 's/######/\n/g' | grep -E -A1 ${ids} | sed 's/^--//g' | egrep -v ^$; done > ../output/listeseqffn.ffn)
## Fin de methode 

## Methodes pour obtenir la liste finale 
# --> Via le clustering
cd-hit-est -i /home/ninon.robin/2023_recup/output/liste_seq_ffn.ffn -o /home/ninon.robin/2023_recup/output/cluster_liste_seq_ffn.ffn -c 1 -n 10 -d 0 -M 17000 -aL 1 
# --> Via un dictionnaire python
./ffn_parser.py
## Fin de methodes