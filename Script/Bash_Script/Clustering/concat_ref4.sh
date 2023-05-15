#!/bin/bash

cd 
cd Projet-Cluster/Data/ResFinder4

for file in  `ls` 
do
    cat $file
    echo -e "\n"
done > /home/ninon.robin/Projet-Cluster/Data/Concat_Data/ResFinder4.fasta
