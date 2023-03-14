library(tidyverse)

#### Ouverture de Parsed_taxonomy.tsv et de ARG_Species.tsv (ou de New_ARG_Species.tsv) & recuperation des donnees ####
Parsed_taxonomy <- read_tsv('W:/ninon-species/output/Table_taxonomie/Parsed_taxonomy.tsv') 

ARG_species <- read_tsv('W:/ninon-species/output/Output_M1/Dataframe/ARG_species.tsv') %>% 
#ARG_species <- read_tsv('W:/ninon-species/output/Output_M1/Dataframe/New_ARG_species.tsv') %>% 
  as.data.frame()

#### Extraction des especes qui n ont pas pu etre matchees lors du join precedent ####
NA_Genus <- is.na(ARG_species[, 'Genus'])
J <- 1

for (i in 1:nrow(ARG_species)) # /!\ On exclus les especes 'bacterium' (!= 'Bacterium') dont les 1eres partie de nom d'espece correspondent a d autres niveaux taxonomiques que le genus
{
  if (NA_Genus[i] == TRUE & grepl('(.*) (bacterium)', ARG_species[i, 'species']) == FALSE) 
  {
    # On complete la colonne des genus en recuperant les 1ere parties de nom d espece (== genus)
    ARG_species[i, 'Genus'] <- str_replace(ARG_species[i, 'species'], '(.*) (.*)', '\\1')
    J <- J + 1
  }
}

# Suppression preventive de certaine lignes de la table de taxonomie pour eviter la creation de certains doublons lors du join 
Parsed_taxonomy <- Parsed_taxonomy[,-c(1)]
Parsed_taxonomy <- Parsed_taxonomy[-c(2051, 4092, 9605),]

#### Creation d une nouvelle dataframe contenant uniquement les especes extraite precedemment & join de celle-ci avec la table de la taxonomie ####
ARG_Genus <- as.data.frame(ARG_species[c(NA_Genus), c('qseqid', 'Centroid', 'shared_by', 'pident', 'qcovhsp', 'sseqid', 'species', 'Genus')])
colnames(ARG_Genus) <- c('qseqid', 'Centroid', 'shared_by', 'pident', 'qcovhsp', 'sseqid', 'species', 'genus')
ARG_Genus <- left_join(ARG_Genus, Parsed_taxonomy, by = c('genus' = 'Genus')) # Cette fois on join directement sur les génus

#### Traitements successifs visant a supprimer les nombreux doublons generes par le join ####
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

# Pourquoi j ai commente ca deja ? 
# double <- grep('Clostridium', ARG_Genus[, 'genus'])
# ARG_Clos <- ARG_Genus[c(double),]
# 
# double7 <- which(ARG_Clos[, 'species'] %in% c('Clostridium aldenense', 'Clostridium clostridioforme', 'Clostridium difficile', 'Clostridium phoceensis'))
# ARG_Target <- ARG_Clos[-c(double7),]
# double8 <- which(ARG_Genus[, 'species'] %in% ARG_Target[, 'species'])
# double9 <- which(ARG_Genus[c(double8), 'Family'] != 'Clostridiaceae')
# ARG_double4 <- ARG_Genus[c(double8),]
# ARG_Genus[c(double8),] <- ARG_double4[-c(double9),]
# 
# ARG_Genus <- unique(ARG_Genus) 

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

#### Remplacement dans notre dataframe initiale des lignes associees aux especes non-matchees par celles de la nouvelle dataframe 
less_NA_genus <- which(ARG_species[, 'species'] %in% ARG_Genus[, 'species'])
ARG_species[c(less_NA_genus),] <- ARG_Genus
na_species <- as.data.frame(unique(ARG_species[is.na(ARG_species[, 'Family']), 'species'])) # Especes encore non-matchees apres ce 2eme join

#### Enregistrement de la dataframe complete dans le fichier Best_ARG_Species.tsv (ou de celle slicee dans le fichier Best_New_ARG_Species.tsv) ####
write.table(ARG_species, "W:/ninon-species/output/Output_M1/Dataframe/Best_ARG_Species.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
#write.table(ARG_species, "W:/ninon-species/output/Output_M1/Dataframe/Best_New_ARG_Species.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
