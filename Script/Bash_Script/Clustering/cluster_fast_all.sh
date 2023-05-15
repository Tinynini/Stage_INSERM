#!/bin/bash

cd 
cd Projet-Cluster/Data

/opt/progs/vsearch --cluster_fast ResFinderAll.fasta --id 0.95 --uc /home/ninon.robin/Projet-Cluster/Output/cluster_fast_all_0.95.txt  

# Les sequences sont groupees en fonction de leur similitude avec les centroides des differents clusters par tailles decroissantes 

<< 'comment'
Clusters: 2697 Size min 1, max 306, avg 3.0
Singletons: 1785, 21.8% of seqs, 66.2% of clusters
comment
