#!/bin/bash

cd 
cd Projet-Cluster/Data

/opt/progs/vsearch --cluster_size uniq_liste_seq_ffn.ffn --id 0.95 --uc /home/ninon.robin/Projet-Cluster/Output/cluster_size_gene_0.95.txt

# Les sequences sont groupees en fonction de leur similitude avec les centroides des differents clusters par abondances decroissantes 

<< 'comment'
Clusters: 25795 Size min 1, max 988, avg 4.9
Singletons: 15563, 12.4% of seqs, 60.3% of clusters
comment