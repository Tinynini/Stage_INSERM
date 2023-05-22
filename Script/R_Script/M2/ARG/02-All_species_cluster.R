#library(tidyverse)

#########################################################################################
# Ninon ROBIN -- ninon.robin@inserm.fr                                                  #
# Utilite == reduire la dataframe en recuperant les centroids obtenus par clustering    #
# et en ne conservant qu un representant de chaque partages au sein de chaque centroids #
# Input == all_species.tsv                                                              #
# Output == sliced_all_species_clust.tsv                                                #
#########################################################################################

#### Ouverture de all_species.tsv et de cluster_fast_all_0.95.txt & recuperation des donnees dans des dataframes ####
all_species <- read_tsv('W:/ninon-species/output/Output_M2/ARG/Dataframe/all_species.tsv', col_types = "ccdddddddddddddcd") %>% 
  as.data.frame()

all_species %>%
  arrange(qseqid, shared_by) %>% 
  identity() -> all_species

#all_clusters <- read_tsv('W:/ninon-species/data/Cluster/Cluster_ARG/cluster_fast_all_0.95.txt', col_names = FALSE, show_col_types = FALSE) %>% 
all_clusters <- read_tsv('W:/ninon-species/data/Cluster/Cluster_AV_AP_ARG/cluster_fast_gene_0.95.txt', col_names = FALSE, show_col_types = FALSE) %>% 
  as.data.frame()

names(all_clusters) <- c('Type', 'Num_cluster', 'Length', '%_Similarity', 'Match_Orientation', 'Unused1', 'Unused2', 'Align_rep', 'Query', 'Centroid')

#### Pretraitement des dataframes en vue de leur join ####
all_centroids <- all_clusters
j <- 1

for (i in 1:nrow(all_clusters)) # Suppression des donnees non pertinentes dans le cadre de notre join
{
  if (all_clusters[i, 'Type'] == 'C')
  {
    all_centroids <- all_centroids[-j,]
  }
  else
  {
    j <- j + 1
  }
}
# Harmonisation des donnees de façon a avoir les labels des centroides associes a chaque sequence de gene (actuellement dispatches dans 2 colonnes) dans une seule et meme colonne 
for (k in 1:nrow(all_centroids)) 
{
  if (all_centroids[k, 'Centroid'] == '*')
  {
    all_centroids[k, 'Centroid'] <- all_centroids[k, 'Query']
  }
}

centro <- as.data.frame(unique(all_centroids[, c('Query', 'Centroid')]))

#### Join des dataframes (== ajout des colonnes 'Centroid' et 'Query') ####
all_species <- left_join(all_species, centro, by = c('qseqid' = 'Query'), keep = FALSE) # On join sur les labels de sequences de gene

all_species %>%
  arrange(Centroid) %>% 
  group_by(Centroid) %>%
  mutate(cluster_shared_by = length(unique(species))) %>%
  identity() -> all_species

all_species <- as.data.frame(t(do.call(rbind, all_species)))

#### Slice de la dataframe sur les especes par centroides de façon a n avoir plus que une seule occurrence par espece et par partage pour un centroid donne ####
# Ca divise pratiquement par 10 le volume initial de la dataframe !! 
all_species %>%
  arrange(Centroid, species, shared_by) %>%
  group_by(Centroid, species, shared_by) %>% 
  slice_tail() -> sliced_all_species

#### Enregistrement de la dataframe slicee dans le fichier Sliced_all_species_clust.tsv ####
write.table(sliced_all_species, "W:/ninon-species/output/Output_M2/ARG/Dataframe/sliced_all_species_clust.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)