library(tidyverse)

#### Ouverture de Parsed_taxonomy.tsv et de all_species_clust.tsv (ou de Sliced_all_species_clust.tsv) & recuperation des donnees ####
Parsed_taxonomy <- read_tsv('W:/ninon-species/output/Parsed_taxonomy.tsv') 

all_species <- read_tsv('W:/ninon-species/output/all_species_clust.tsv') %>% 
#all_species <- read_tsv('W:/ninon-species/output/sliced_all_species_clust.tsv') %>%
  as.data.frame()

#### Creation d une nouvelle dataframe a partir des colonnes de notre dataframe actuelle selectionnees et reordonnees selon nos besoins ####
ARG_Species <- as.data.frame(c(all_species['qseqid'], all_species['Centroid'], all_species['shared_by'],  all_species['pident'], all_species['qcovhsp'], all_species['sseqid'], all_species['species']))

#### Modification de la nomenclature de notre nouvelle dataframe en vue de son join avec la table de taxonomie ####
ARG_Species[, 'species'] <- str_replace(ARG_Species[, 'species'], pattern = '(.*)(_)(.*)', replacement = "\\1\\ \\3")

Species <- unlist(ARG_Species['species'])

for (j in 1:nrow(ARG_Species)) # Traitement supplementaire pour les especes 'UNVERIFIED_ORG' 
{
  if (endsWith(Species[j], 'ORG-.') == TRUE)
  {
    ARG_Species[j,'species'] <- str_replace(ARG_Species[j,'species'], pattern = "(.*)_(.*) (.*)(..)", replacement = "\\1\\ \\2\\_\\3")
  }
}

# Inversion des 2 parties de nom d'espece pour les especes 'Bacterium' pour avoir la bonne nomenclatuture
err <- grep('(Bacterium) (.*)', ARG_Species[, 'species']) 
ARG_Species[err, 'species'] <- str_replace(ARG_Species[err, 'species'], '(Bacterium) (.*)', '\\2\\ \\1')

#### Join de notre nouvelle dataframe et de la tables de taxonomie (== ajout des colonnes 'Genus', 'Family', 'Order', 'Class', 'Phylum' et 'Domain') ####
ARG_Species %>% 
  arrange(qseqid) %>% 
  identity() -> ARG_Species

ARG_Species <- left_join(ARG_Species, Parsed_taxonomy, by = c('species' = 'Species')) # On join sur les noms d'especes
na_species <- as.data.frame(unique(ARG_Species[is.na(ARG_Species[, 'Genus']), 'species'])) # Especes n ayant pas pu etre matchees avec celle de la table de taxonomie

#### Enregistrement de la nouvelle dataframe complete dans le fichier ARG_Species.tsv (ou de celle slicee dans le fichier New_ARG_Species.tsv) ####
write.table(ARG_Species, "W:/ninon-species/output/ARG_Species.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
#write.table(ARG_Species, "W:/ninon-species/output/New_ARG_Species.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
