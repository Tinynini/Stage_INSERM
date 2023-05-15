#!/bin/bash

cd 
cd Projet-Cluster/Data/Concat_Data

/opt/progs/vsearch --cluster_size ResFinder_FG.fasta --id 0.95 --uc /home/ninon.robin/Projet-Cluster/Output/cluster_size_FG_0.95.txt

# Les sequences sont groupees en fonction de leur similitude avec les centroides des differents clusters par abondances decroissantes 

<< 'comment'
Clusters: 1932 Size min 1, max 238, avg 2.6
Singletons: 1315, 26.1% of seqs, 68.1% of clusters
comment
