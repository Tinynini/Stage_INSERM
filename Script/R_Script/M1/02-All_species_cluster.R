library(tidyverse)

#### Ouverture de all_species.tsv et de cluster_fast_all_0.95.txt & recuperation des donnees dans des dataframes ####
all_species <- read_tsv('W:/ninon-species/output/Output_M1/Dataframe/all_species.tsv') %>% 
  as.data.frame()

all_species %>%
  arrange(qseqid, shared_by) %>% 
  identity() -> all_species

all_clusters <- read_tsv('W:/ninon-species/data/Cluster/Cluster_ARG/cluster_fast_all_0.95.txt', col_names = FALSE) %>% 
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

# Harmonisation des donnees de fa�on a avoir les labels des centroides associes a chaque sequence d'ARG (actuellement dispatches dans 2 colonnes) dans une seule et meme colonne 
for (k in 1:nrow(all_centroids)) 
{
  if (all_centroids[k, 'Centroid'] == '*')
  {
    all_centroids[k, 'Centroid'] <- all_centroids[k, 'Query']
  }
}

centro <- as.data.frame(unique(all_centroids[, c('Query', 'Centroid')]))

#### Join des dataframes (== ajout des colonnes 'Centroid' et 'Query') ####
all_species <- rev(all_species)
all_species <- left_join(all_species, centro, by = c('qseqid' = 'Query'), keep = TRUE) # On join sur les labels de sequences d'ARG
all_species <- rev(all_species)

all_species %>%
  arrange(Centroid) %>% 
  group_by(Centroid) %>%
  mutate(cluster_shared_by = length(unique(species))) %>%
  identity() -> all_species

all_species <- as.data.frame(t(do.call(rbind, all_species)))

#### Slice de la dataframe sur les especes par centroides de fa�on a n avoir plus que une seule occurrence par espece pour un centroid donne ####
all_species %>%
  arrange(Centroid, species, shared_by) %>%
  group_by(Centroid, species) %>% 
  slice_tail() -> sliced_all_species
# Ca divise pratiquement par 10 le volume initial de la dataframe !! 
sliced_all_species <- as.data.frame(t(do.call(rbind, sliced_all_species))) 

#### Enregistrement de la dataframe complete dans le fichier all_species_clust.tsv et de celle slicee dans le fichier Sliced_all_species_clust.tsv ####
write.table(all_species, "W:/ninon-species/output/Output_M1/Dataframe/all_species_clust.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
write.table(sliced_all_species, "W:/ninon-species/output/Output_M1/Dataframe/sliced_all_species_clust.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)