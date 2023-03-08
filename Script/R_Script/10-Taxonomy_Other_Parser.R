library(tidyverse)

#### Ouverture de Parsed_taxonomy.tsv et de Best_ARG_Species.tsv (ou de Best_New_ARG_Species.tsv) & récupération des données ####
Parsed_taxonomy <- read_tsv('W:/ninon-species/output/Parsed_taxonomy.tsv') 

ARG_species <- read_tsv('W:/ninon-species/output/Best_ARG_species.tsv') %>% 
#ARG_species <- read_tsv('W:/ninon-species/output/Best_New_ARG_species.tsv') %>% 
  as.data.frame()

#### Extraction des espèces 'bacterium' qui ne peuvent pas être matchées qu'au niveau de la famille ####
NA_Genus <- is.na(ARG_species[, 'Genus'])
J <- 1

for (i in 1:nrow(ARG_species)) 
{
  if (NA_Genus[i] == TRUE & grepl('(.*)(ceae) (bacterium)', ARG_species[i, 'species']) == TRUE)
  {
    # On complète la colonne des familles en récupérant les 1ère parties de nom d'espèce (== Famille dans ce cas)
    ARG_species[i, 'Family'] <- str_replace(ARG_species[i, 'species'], '(.*) (.*)', '\\1')
    J <- J + 1
  }
}

# Suppression des colonnes des espèces et des génus dans la table de taxonomie en vue du join 
Parsed_taxonomy <- Parsed_taxonomy[,-c(1, 2)]

#### Création d'une nouvelle dataframe contenant uniquement les espèces extraite précédemment & join de celle-ci avec la table de la taxonomie ####
ARG_Family <- as.data.frame(ARG_species[c(NA_Genus), c('qseqid', 'Centroid', 'shared_by', 'pident', 'qcovhsp', 'sseqid', 'species', 'Genus', 'Family')])
colnames(ARG_Family) <- c('qseqid', 'Centroid', 'shared_by', 'pident', 'qcovhsp', 'sseqid', 'species', 'genus', 'family')

ARG_Family <- left_join(ARG_Family, Parsed_taxonomy, by = c('family' = 'Family')) # Cette fois on join directement sur les familles
ARG_Family <- unique(ARG_Family)

#### Remplacement dans notre dataframe initiale des lignes associées aux espèces non-matchées par celles de la nouvelle dataframe 
less_NA_Family <- which(ARG_species[, 'species'] %in% ARG_Family[, 'species'])
ARG_species[c(less_NA_Family),] <- ARG_Family
NA_Family <- is.na(ARG_species[, 'Family']) # Especes encore non-matchées après ce 3ème join

#### Extraction des espèces 'bacterium' qui ne peuvent pas être matchées qu'au niveau de l'ordre ####
J <- 1

for (i in 1:nrow(ARG_species))
{
  if (NA_Family[i] == TRUE & grepl('(.*)(ales) (bacterium)', ARG_species[i, 'species']) == TRUE)
  {
    # On complète la colonne des ordres en récupérant les 1ère parties de nom d'espèce (== Ordre dans ce cas)
    ARG_species[i, 'Order'] <- str_replace(ARG_species[i, 'species'], '(.*) (.*)', '\\1')
    J <- J + 1
  }
}

# Suppression de la colonnes des familles dans la table de taxonomie en vue du join 
Parsed_taxonomy <- Parsed_taxonomy[,-c(1)]

#### Création d'une nouvelle dataframe contenant uniquement les espèces extraite précédemment & join de celle-ci avec la table de la taxonomie ####
ARG_Order <- as.data.frame(ARG_species[c(NA_Family), c('qseqid', 'Centroid', 'shared_by', 'pident', 'qcovhsp', 'sseqid', 'species', 'Genus', 'Family', 'Order')])
colnames(ARG_Order) <- c('qseqid', 'Centroid', 'shared_by', 'pident', 'qcovhsp', 'sseqid', 'species', 'genus', 'family', 'order')

ARG_Order <- left_join(ARG_Order, Parsed_taxonomy, by = c('order' = 'Order'))
ARG_Order <- unique(ARG_Order)

#### Remplacement dans notre dataframe initiale des lignes associées aux espèces non-matchées par celles de la nouvelle dataframe 
less_NA_Order <- which(ARG_species[, 'species'] %in% ARG_Order[, 'species'])
ARG_species[c(less_NA_Order),] <- ARG_Order

#### Traitement directe (hors join) de 3 cas particuliés d'espèces 'bactérium' trop isolé pour faire l'objet d'un join ####
ex1 <- which(ARG_species[, 'species'] == 'Bacillus bacterium') 
ARG_species[ex1, c('Genus', 'Family', 'Order', 'Class', 'Phylum', 'Domain')] <- 
  c('Bacillus', 'Bacillaceae', 'Bacillales', 'Bacilli', 'Firmicutes', 'Bacteria')

ex2 <- which(ARG_species[, 'species'] == 'Clostridia bacterium') 
ARG_species[ex2, 'Class'] <- 'Clostridia'
ARG_species[ex2, 'Phylum'] <- 'Firmicutes'
ARG_species[ex2, 'Domain'] <- 'Bacteria'

ex3 <- which(ARG_species[, 'species'] == 'Firmicutes bacterium') 
ARG_species[ex3, 'Phylum'] <- 'Firmicutes'
ARG_species[ex3, 'Domain'] <- 'Bacteria'

na_species <- as.data.frame(unique(ARG_species[is.na(ARG_species[, 'Domain']), 'species'])) # Especes restées non-matchées in fine

#### Enregistrement de la dataframe complète dans le fichier Final_ARG_Species.tsv (ou de celle slicée dans le fichier Final_New_ARG_Species.tsv) ####
write.table(ARG_species, "W:/ninon-species/output/Final_ARG_Species.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
#write.table(ARG_species, "W:/ninon-species/output/Final_New_ARG_Species.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
