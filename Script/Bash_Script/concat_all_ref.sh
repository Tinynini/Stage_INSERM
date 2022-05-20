#!/bin/bash

cd 
cd Projet-Cluster/Data/Concat_Data

for file in  `ls` 
do
    cat $file
    echo -e "\n"
done > /home/ninon.robin/Projet-Cluster/Data/ResFinderAll.fasta