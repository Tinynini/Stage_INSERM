#!/bin/bash

cd 
cd Projet-Cluster/Data

/opt/progs/vsearch --cluster_fast uniq_liste_seq_ffn.ffn --id 0.95 --uc /home/ninon.robin/Projet-Cluster/Output/cluster_fast_gene_0.95.txt  

# Les sequences sont groupees en fonction de leur similitude avec les centroides des differents clusters par tailles decroissantes 

<< 'comment'
Clusters: 26053 Size min 1, max 1434, avg 4.8
Singletons: 15550, 12.4% of seqs, 59.7% of clusters
comment
