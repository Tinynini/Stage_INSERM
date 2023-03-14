library(tidyverse)

#### Ouverture de Parsed_taxonomy.tsv et de Best_ARG_Species.tsv (ou de Best_New_ARG_Species.tsv) & recuperation des donnees ####
Parsed_taxonomy <- read_tsv('W:/ninon-species/output/Table_taxonomieParsed_taxonomy.tsv') 

ARG_species <- read_tsv('W:/ninon-species/output/Output_M1/Dataframe/Best_ARG_species.tsv') %>% 
#ARG_species <- read_tsv('W:/ninon-species/output/Output_M1/Dataframe/Best_New_ARG_species.tsv') %>% 
  as.data.frame()

#### Extraction des especes 'bacterium' qui ne peuvent etre matchees que au niveau de la famille ####
NA_Genus <- is.na(ARG_species[, 'Genus'])
J <- 1

for (i in 1:nrow(ARG_species)) 
{
  if (NA_Genus[i] == TRUE & grepl('(.*)(ceae) (bacterium)', ARG_species[i, 'species']) == TRUE)
  {
    # On complete la colonne des familles en recuperant les 1ere parties de nom d'espece (== Famille dans ce cas)
    ARG_species[i, 'Family'] <- str_replace(ARG_species[i, 'species'], '(.*) (.*)', '\\1')
    J <- J + 1
  }
}

# Suppression des colonnes des especes et des genus dans la table de taxonomie en vue du join 
Parsed_taxonomy <- Parsed_taxonomy[,-c(1, 2)]

#### Creation d une nouvelle dataframe contenant uniquement les especes extraite precedemment & join de celle-ci avec la table de la taxonomie ####
ARG_Family <- as.data.frame(ARG_species[c(NA_Genus), c('qseqid', 'Centroid', 'shared_by', 'pident', 'qcovhsp', 'sseqid', 'species', 'Genus', 'Family')])
colnames(ARG_Family) <- c('qseqid', 'Centroid', 'shared_by', 'pident', 'qcovhsp', 'sseqid', 'species', 'genus', 'family')

ARG_Family <- left_join(ARG_Family, Parsed_taxonomy, by = c('family' = 'Family')) # Cette fois on join directement sur les familles
ARG_Family <- unique(ARG_Family)

#### Remplacement dans notre dataframe initiale des lignes associees aux especes non-matchees par celles de la nouvelle dataframe 
less_NA_Family <- which(ARG_species[, 'species'] %in% ARG_Family[, 'species'])
ARG_species[c(less_NA_Family),] <- ARG_Family
NA_Family <- is.na(ARG_species[, 'Family']) # Especes encore non-matchees après ce 3eme join

#### Extraction des especes 'bacterium' qui ne peuvent pas etre matchees qu au niveau de l ordre ####
J <- 1

for (i in 1:nrow(ARG_species))
{
  if (NA_Family[i] == TRUE & grepl('(.*)(ales) (bacterium)', ARG_species[i, 'species']) == TRUE)
  {
    # On complete la colonne des ordres en recuperant les 1ere parties de nom d espece (== Ordre dans ce cas)
    ARG_species[i, 'Order'] <- str_replace(ARG_species[i, 'species'], '(.*) (.*)', '\\1')
    J <- J + 1
  }
}

# Suppression de la colonnes des familles dans la table de taxonomie en vue du join 
Parsed_taxonomy <- Parsed_taxonomy[,-c(1)]

#### Creation d une nouvelle dataframe contenant uniquement les especes extraite precedemment & join de celle-ci avec la table de la taxonomie ####
ARG_Order <- as.data.frame(ARG_species[c(NA_Family), c('qseqid', 'Centroid', 'shared_by', 'pident', 'qcovhsp', 'sseqid', 'species', 'Genus', 'Family', 'Order')])
colnames(ARG_Order) <- c('qseqid', 'Centroid', 'shared_by', 'pident', 'qcovhsp', 'sseqid', 'species', 'genus', 'family', 'order')

ARG_Order <- left_join(ARG_Order, Parsed_taxonomy, by = c('order' = 'Order'))
ARG_Order <- unique(ARG_Order)

#### Remplacement dans notre dataframe initiale des lignes associees aux especes non-matchees par celles de la nouvelle dataframe 
less_NA_Order <- which(ARG_species[, 'species'] %in% ARG_Order[, 'species'])
ARG_species[c(less_NA_Order),] <- ARG_Order

#### Traitement directe (hors join) de 3 cas particulies d'especes 'bactérium' trop isole pour faire l objet d'un join ####
ex1 <- which(ARG_species[, 'species'] == 'Bacillus bacterium') 
ARG_species[ex1, c('Genus', 'Family', 'Order', 'Class', 'Phylum', 'Domain')] <- 
  c('Baccilus', 'Bacillaceae', 'Bacillales', 'Bacilli', 'Firmicutes', 'Bacteria')

ex2 <- which(ARG_species[, 'species'] == 'Clostridia bacterium') 
ARG_species[ex2, 'Class'] <- 'Clostridia'
ARG_species[ex2, 'Phylum'] <- 'Firmicutes'
ARG_species[ex2, 'Domain'] <- 'Bacteria'

ex3 <- which(ARG_species[, 'species'] == 'Firmicutes bacterium') 
ARG_species[ex3, 'Phylum'] <- 'Firmicutes'
ARG_species[ex3, 'Domain'] <- 'Bacteria'

# Est ce aussi necessaire ici ??
# ex4 <- which(all_species[, 'species'] == 'Lachnospiraceae oral')
# all_species[ex4, 'Genus'] <- NA
# all_species[ex4, 'Family'] <- 'Lachnospiraceae' 
# all_species[ex4, 'Order'] <- 'Lachnospirales'

na_species <- as.data.frame(unique(ARG_species[is.na(ARG_species[, 'Domain']), 'species'])) # Especes restees non-matchees in fine

#### Enregistrement de la dataframe complete dans le fichier Final_ARG_Species.tsv (ou de celle slicee dans le fichier Final_New_ARG_Species.tsv) ####
write.table(ARG_species, "W:/ninon-species/output/Output_M1/Dataframe/Final_ARG_Species.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
#write.table(ARG_species, "W:/ninon-species/output/Output_M1/Dataframe/Final_New_ARG_Species.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
