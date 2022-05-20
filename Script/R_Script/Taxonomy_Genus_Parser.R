library(tidyverse)

#### Ouverture de Parsed_taxonomy.tsv et de ARG_Species.tsv (ou de New_ARG_Species.tsv) & récupération des données ####
Parsed_taxonomy <- read_tsv('W:/ninon-species/output/Parsed_taxonomy.tsv') 

ARG_species <- read_tsv('W:/ninon-species/output/ARG_species.tsv') %>% 
#ARG_species <- read_tsv('W:/ninon-species/output/New_ARG_species.tsv') %>% 
  as.data.frame()

#### Extraction des espèces qui n'ont pas pû être matchées lors du join précédent ####
NA_Genus <- is.na(ARG_species[, 'Genus'])
J <- 1

for (i in 1:nrow(ARG_species)) # /!\ On exclus les espèces 'bacterium' (!= 'Bacterium') dont les 1ères partie de nom d'espèce correspondent à d'autres niveaux taxonomiques que le génus
{
  if (NA_Genus[i] == TRUE & grepl('(.*) (bacterium)', ARG_species[i, 'species']) == FALSE) 
  {
    # On complète la colonne des génusen récupérant les 1ère parties de nom d'espèce (== génus)
    ARG_species[i, 'Genus'] <- str_replace(ARG_species[i, 'species'], '(.*) (.*)', '\\1')
    J <- J + 1
  }
}

# Suppression préventive de certaine lignes de la table de taxonomie pour éviter la création de certains doublons lors du join et de la colonne des espèces 
Parsed_taxonomy <- Parsed_taxonomy[-2051,]
Parsed_taxonomy <- Parsed_taxonomy[-4091,]
Parsed_taxonomy <- Parsed_taxonomy[-9605,]
Parsed_taxonomy <- Parsed_taxonomy[,-1]

#### Création d'une nouvelle dataframe contenant uniquement les espèces extraite précédemment & join de celle-ci avec la table de la taxonomie ####
ARG_Genus <- as.data.frame(ARG_species[c(NA_Genus), c('qseqid', 'Centroid', 'shared_by', 'pident', 'qcovhsp', 'sseqid', 'species', 'Genus')])
colnames(ARG_Genus) <- c('qseqid', 'Centroid', 'shared_by', 'pident', 'qcovhsp', 'sseqid', 'species', 'genus')
ARG_Genus <- left_join(ARG_Genus, Parsed_taxonomy, by = c('genus' = 'Genus')) # Cette fois on join directement sur les génus

#### Traitements successifs visant à supprimer les nombreux doublons générés par le join (On ne peut pas systématiser l'opération) ####
ARG_Genus <- unique(ARG_Genus)

double1 <- which(ARG_Genus[, 'species'] %in% c('Clostridium aldenense', 'Clostridium clostridioforme'))
double2 <- which(ARG_Genus[c(double1), 'Family'] != 'Lachnospiraceae')
ARG_double <- ARG_Genus[c(double1),]
ARG_Genus[c(double1),] <- ARG_double[-c(double2),]

ARG_Genus <- unique(ARG_Genus) 

double3 <- which(ARG_Genus[, 'species'] == 'Clostridium difficile')
double4 <- which(ARG_Genus[c(double3), 'Family'] != 'Peptostreptococcaceae')
ARG_double2 <- ARG_Genus[c(double3),]
ARG_Genus[c(double3),] <- ARG_double2[-c(double4),]

ARG_Genus <- unique(ARG_Genus) 

double5 <- which(ARG_Genus[, 'species'] == 'Clostridium phoceensis')
double6 <- which(ARG_Genus[c(double5), 'Family'] != 'Acutalibacteraceae')
ARG_double3 <- ARG_Genus[c(double5),]
ARG_Genus[c(double5),] <- ARG_double3[-c(double6),]

ARG_Genus <- unique(ARG_Genus) 

double <- grep('Clostridium', ARG_Genus[, 'genus'])
ARG_Clos <- ARG_Genus[c(double),]

double7 <- which(ARG_Clos[, 'species'] %in% c('Clostridium aldenense', 'Clostridium clostridioforme', 'Clostridium difficile', 'Clostridium phoceensis'))
ARG_Target <- ARG_Clos[-c(double7),]
double8 <- which(ARG_Genus[, 'species'] %in% ARG_Target[, 'species'])
double9 <- which(ARG_Genus[c(double8), 'Family'] != 'Clostridiaceae')
ARG_double4 <- ARG_Genus[c(double8),]
ARG_Genus[c(double8),] <- ARG_double4[-c(double9),]

ARG_Genus <- unique(ARG_Genus) 

double10 <- which(ARG_Genus[, 'genus'] == 'Ruminococcus')
double11 <- which(ARG_Genus[c(double10), 'Family'] != 'Ruminococcaceae')
ARG_double5 <- ARG_Genus[c(double10),]
ARG_Genus[c(double10),] <- ARG_double5[-c(double11),]

ARG_Genus <- unique(ARG_Genus) 

double12 <- which(ARG_Genus[, 'genus'] == 'Eubacterium')
double13 <- which(ARG_Genus[c(double12), 'Family'] != 'Eubacteriaceae')
ARG_double6 <- ARG_Genus[c(double12),]
ARG_Genus[c(double12),] <- ARG_double6[-c(double13),]

ARG_Genus <- unique(ARG_Genus) 

double14 <- which(ARG_Genus[, 'genus'] == 'Mycoplasma')
double15 <- which(ARG_Genus[c(double14), 'Family'] != 'Mycoplasmataceae')
ARG_double7 <- ARG_Genus[c(double14),]
ARG_Genus[c(double14),] <- ARG_double7[-c(double15),]

ARG_Genus <- unique(ARG_Genus) 

double16 <- which(ARG_Genus[, 'genus'] == 'Paenibacillus')
double17 <- which(ARG_Genus[c(double16), 'Family'] != 'Paenibacillaceae')
ARG_double8 <- ARG_Genus[c(double16),]
ARG_Genus[c(double16),] <- ARG_double8[-c(double17),]

ARG_Genus <- unique(ARG_Genus) 

#### Remplacement dans notre dataframe initiale des lignes associées aux espèces non-matchées par celles de la nouvelle dataframe 
less_NA_genus <- which(ARG_species[, 'species'] %in% ARG_Genus[, 'species'])
ARG_species[c(less_NA_genus),] <- ARG_Genus
na_species <- as.data.frame(unique(ARG_species[is.na(ARG_species[, 'Family']), 'species'])) # Especes encore non-matchées après ce 2ème join

#### Enregistrement de la dataframe complète dans le fichier Best_ARG_Species.tsv (ou de celle slicée dans le fichier Best_New_ARG_Species.tsv) ####
write.table(ARG_species, "W:/ninon-species/output/Best_ARG_Species.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
#write.table(ARG_species, "W:/ninon-species/output/Best_New_ARG_Species.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)