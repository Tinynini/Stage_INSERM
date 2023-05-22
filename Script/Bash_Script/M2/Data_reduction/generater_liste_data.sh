#!/bin/bash

res_4_path="/home/ninon.robin/diamond_resfinder4/"
res_FG_path="/home/ninon.robin/diamond_resfinderFG/"

find ${res_4_path} -name "*.tsv" > ../data/arg_species.txt
find ${res_FG_path} -name "*.tsv" >> ../data/arg_species.txt

arg_species='../data/arg_species.txt'

for path in ${arg_species}
do
   cat $(cat ${path}) | awk '{print $2}' 
done > ../data/liste_arg.txt 

cat ../data/liste_arg.txt | sort | uniq > ../data/order_liste_arg.txt 
rm ../data/liste_arg.txt 

gff_path="/home/REFSEQ/prokka/"
find ${gff_path} -name "*.gff" > ../data/liste_gff.txt

cat ../data/liste_gff.txt | sed 's/gff/ffn/g' > ../data/liste_ffn.txt 
cat ../data/liste_gff.txt | sort -t '/' -k 6 > ../data/order_liste_gff.txt
cat ../data/liste_ffn.txt | sort -t '/' -k 6 > ../data/order_liste_ffn.txt