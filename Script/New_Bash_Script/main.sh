#!/bin/bash

dir1="/home/ninon.robin/gff/"
dir2="/home/ninon.robin/usefull/"
dir3="/home/ninon.robin/listes_id/"
dir4="/home/ninon.robin/listes_gene/"

end1='_usefull.txt'
end2='_liste_id.txt'
end3='_uniq_liste_id.txt'
end4='_uniq_liste_gene.txt'

# 1 Extraction des sseqid depuis diamond avec sseqid_extractor.py --> sseqid.txt --> uniq_sseqid.txt

./sseqid_extractor.py

cat sseqid.txt | sort | uniq > uniq_sseqid.txt

# 2 Tag des IDs de gènes et des configs dans les fichiers .gff --> usefull.txt

for file in `ls $dir1` 
do
    fichier=$dir1$file
    filename=`echo "$file" | cut -f 1 -d '.'`
    cat $fichier | grep 'prokka' | awk '{print substr($1, 33, 5)"\n"substr($9, 1, 22)}' | tr -d 'ID=' | uniq > $dir2$filename$end1 
done

# 3 Extraction des IDs de gènes avant et après les ARGss s'ils viennent bien du même contig que l'ARG --> liste_id.txt --> uniq_liste_id.txt

./id_extractor.py 

for file in `ls $dir3` 
do
    fichier=$dir3$file
    filename=`echo "$file" | cut -f 1 -d '.' | cut -f 1-2 -d '_'`
    cat $fichier | sort | uniq > $dir3$filename$end3
    rm $fichier
done

for file in `ls $dir4` 
do
    fichier=$dir4$file
    filename=`echo "$file" | cut -f 1 -d '.' | cut -f 1-2 -d '_'`
    cat $fichier | uniq > $dir4$filename$end4
    rm $fichier
done

# 4 Extraction des séquences associées aux gènes de la liste --> liste_seq.ffn

./seq_extractor.py 