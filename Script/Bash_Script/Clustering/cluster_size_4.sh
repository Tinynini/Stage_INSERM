#!/bin/bash

cd 
cd Projet-Cluster/Data/Concat_Data

/opt/progs/vsearch --cluster_size ResFinder4.fasta --id 0.95 --uc /home/ninon.robin/Projet-Cluster/Output/cluster_size_4_0.95.txt

# Les sequences sont groupees en fonction de leur similitude avec les centroides des differents clusters par abondances decroissantes 

<< 'comment'
Clusters: 848 Size min 1, max 183, avg 3.7
Singletons: 529, 16.7% of seqs, 62.4% of clusters
comment
