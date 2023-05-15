#!/bin/bash

cd 
cd Projet-Cluster/Data/Concat_Data

/opt/progs/vsearch --cluster_fast ResFinder_FG.fasta --id 0.95 --uc /home/ninon.robin/Projet-Cluster/Output/cluster_fast_FG_0.95.txt  

# Les sequences sont groupees en fonction de leur similitude avec les centroides des differents clusters par tailles decroissantes 

<< 'comment'
Clusters: 1933 Size min 1, max 234, avg 2.6
Singletons: 1312, 26.1% of seqs, 67.9% of clusters
comment
