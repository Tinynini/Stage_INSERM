#!/bin/bash

./generater_liste_data.sh

liste_id="/home/ninon.robin/2023_recup/output/order_liste_id.txt"
liste_seq="/home/ninon.robin/2023_recup/output/order_liste_seq.txt"
liste_ffn="/home/ninon.robin/2023_recup/data/order_liste_ffn.txt"

## Methode sans tableau pour les ffn --> +3h30 donc ca va !
for seq in $(cat ${liste_seq}) 
do 
    ffn=$(grep ${seq} ${liste_ffn})
    ids=$(cat ${liste_id} | grep ${seq} | awk '{print $0"|"}' | tr -d '\n')
    ids=${ids%?}
    cat ${ffn} | sed 's/^>\(.*\)$/######>\1######/g' | tr -d '\n' | sed 's/######/\n/g' | grep -E -A1 ${ids} | sed 's/^--//g' | egrep -v ^$
done > /home/ninon.robin/2023_recup/output/liste_seq_ffn.ffn
## Fin de methode

## Methode avec tableau pour les ffn --> -3h30 donc encore mieux !
declare -A table_ffn

for line in $(cat ${liste_ffn})
do 
    key=$(basename ${line})
    key=${key%.ffn}
    table_ffn[${key}]=${line}
done 

echo '2nd partie'

for seq in $(cat ${liste_seq}) 
do 
    curr_key=$(echo ${seq})
    ffn=$(echo ${table_ffn[${curr_key}]})
    ids=$(cat ${liste_id} | grep ${seq} | awk '{print $0"|"}' | tr -d '\n')
    ids=${ids%?}
    cat ${ffn} | sed 's/^>\(.*\)$/######>\1######/g' | tr -d '\n' | sed 's/######/\n/g' | grep -E -A1 ${ids} | sed 's/^--//g' | egrep -v ^$
done > /home/ninon.robin/2023_recup/output/liste_seq_ffn.ffn
## Fin de methode 

## Methodes pour obtenir la liste finale 
# --> Via le clustering
cd-hit-est -i /home/ninon.robin/2023_recup/output/liste_seq_ffn.ffn -o /home/ninon.robin/2023_recup/output/cluster_liste_seq_ffn.ffn -c 1 -n 10 -d 0 -M 17000 -aL 1 
# --> Via un dictionnaire python
./ffn_parser.py
## Fin de methodes
