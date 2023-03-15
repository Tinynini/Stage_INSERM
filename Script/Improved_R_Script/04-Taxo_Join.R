library(tidyverse)

#### Ouverture de Parsed_taxonomy.tsv et de Sliced_all_species_clust.tsv & recuperation des donnees ####
Parsed_taxonomy <- read_tsv('W:/ninon-species/output/Table_taxonomie/Parsed_taxonomy.tsv')
Parsed_taxonomy <- Parsed_taxonomy[-c(2051, 4092, 9605),] # Suppression preventive de certaine lignes de la table de taxonomie pour eviter l apparition de certains doublons 

all_species <- read_tsv('W:/ninon-species/output/Output_M2/ARG/Dataframe/sliced_all_species_clust.tsv') %>%
  as.data.frame()

#### fonction servant a supprimer de maniere systematique certain types de doublons post-joint ####
Genus_cleaner <- function(df, level, doublon, ref)
{
  double1 <- which(df[, level] %in% doublon)
  double2 <- which(df[c(double1), 'Family'] != ref)
  ARG_double <- df[c(double1),]
  df[c(double1),] <- ARG_double[-c(double2),]
  
  df <- unique(df)
}

#### fonction (utilisant celle ci-avant) servant a gerer l ensemble des doublon crees lors du join au niveau des genus ####
Genus_cleaning <- function(df)
{
  df <- Genus_cleaner(df, 'species', c('Clostridium aldenense', 'Clostridium clostridioforme'), 'Lachnospiraceae')
  df <- Genus_cleaner(df, 'species', 'Clostridium difficile', 'Peptostreptococcaceae')
  df <- Genus_cleaner(df, 'species', 'Clostridium phoceensis', 'Acutalibacteraceae')
  df <- Genus_cleaner(df, 'Genus', 'Ruminococcus', 'Lachnospiraceae')
  df <- Genus_cleaner(df, 'Genus', 'Eubacterium', 'Eubacteriaceae')
  df <- Genus_cleaner(df, 'Genus', 'Mycoplasma', 'Mycoplasmataceae')
  
  double <- grep('Clostridium', df[, 'Genus'])
  ARG_Clos <- df[c(double),]
  
  double1 <- which(ARG_Clos[, 'species'] %in% c('Clostridium aldenense', 'Clostridium clostridioforme', 'Clostridium difficile', 'Clostridium phoceensis'))
  ARG_Target <- ARG_Clos[-c(double1),]
  double2 <- which(df[, 'species'] %in% ARG_Target[, 'species'])
  double3 <- which(df[c(double2), 'Family'] != 'Clostridiaceae')
  ARG_double <- df[c(double2),]
  df[c(double2),] <- ARG_double[-c(double3),]
  
  df <- unique(df)
}

#### Preparation des donnees en vue d un 1er join au niveau des especes ####
# On reordonne les colonnes en vue du join en ne gardant que celles dont on a besoin pour la suite  
all_species <- all_species[, c('qseqid', 'Centroid', 'shared_by', 'pident', 'qcovhsp', 'sseqid', 'species')]
# On modifie la nomenclature des noms d especes en vue du join 
all_species[, 'species'] <- str_replace(all_species[, 'species'], pattern = '(.*)(_)(.*)', replacement = "\\1\\ \\3")

Species <- unlist(all_species['species'])

for (j in 1:nrow(all_species)) # Certain noms d especes necessitent un traitement supplementaire
{
  if (endsWith(Species[j], 'ORG-.') == TRUE) # Traitement supplementaire pour les especes 'UNVERIFIED_ORG'
  {
    all_species[j,'species'] <- str_replace(all_species[j,'species'], pattern = "(.*)_(.*) (.*)(..)", replacement = "\\1\\ \\2\\_\\3")
  }
  
  if (endsWith(Species[j], 'symbiont') == TRUE) # Traitement supplementaire pour les especes 'symbiont'
  {
    all_species[j,'species'] <- str_replace(all_species[j,'species'], pattern = "(.*) (.*)", replacement = "\\2\\ \\1")
  }
  
  if (startsWith(Species[j], 'Bacterium') == TRUE) # Traitement supplementaire pour les especes 'Bacterium'
  {
    all_species[j,'species'] <- str_replace(all_species[j,'species'], pattern = "(.*) (.*)", replacement = "\\2\\ \\1")
  }
}

#### 1er join au niveau des especes --> consequence : ajout de 6 nouvelle colonnes ('Genus' a 'Domain') ####
all_species %>%
  arrange(qseqid) %>%
  identity() -> all_species

all_species <- left_join(all_species, Parsed_taxonomy, by = c('species' = 'Species'))

#### Preparation des donnees en vue des 3 joins successifs a venir ####
level_name <- unlist(colnames(Parsed_taxonomy[, c(1:4)]))
level_name[1] <- 'species'
# On liste les suffix des especes 'bacterium' pour pouvoir les traiter selon le niveau taxonomique a partir duquel elles sont referencees
suffix <- c('', '(.*) (bacterium)', '(.*)(ceae) (bacterium)', '(.*)(ales) (bacterium)')
cond <- c('', FALSE, TRUE, TRUE) # On adapte la condition de traitement selon le niveau taxonomique
NA_level <- is.na(all_species[, level_name[2]]) # Extraction des especes qui n ont pas pu etre matchees lors du 1er join 

#### joins successifs au niveau des genus puis des familles et enfin des ordres ####
for (i in 2:4)
{
  # On supprime le niveau traite precedement de la table de taxonomie en vue du nouveau join
  Parsed_taxonomy <- Parsed_taxonomy[,-c(1)] 
  
  # Traitement specifiques des especes 'bacterium' qui ne peuvent etre matchees qu au niveau i 
  for (k in 1:nrow(all_species))
  {
    if (NA_level[k] == TRUE & grepl(suffix[i], all_species[k, 'species']) == cond[i])
    {
      all_species[k, level_name[i]] <- str_replace(all_species[k, 'species'], '(.*) (.*)', '\\1')
    }
  }
  
  # Creation d une nouvelle dataframe contenant uniquement les especes non matchee lors du join precedent
  ARG_level <- as.data.frame(all_species[c(NA_level), c(1:(i + 6))])
  colnames(ARG_level) <- colnames(all_species[, c(1:(i + 6))])
  ARG_level <- left_join(ARG_level, Parsed_taxonomy, by = NULL)
  ARG_level <- unique(ARG_level)
  
  #### Traitement visant a supprimer les nombreux doublons generes par le join au niveau des genus ####
  if (i == 2)
  {
    ARG_level <- Genus_cleaning(ARG_level)
  }
  
  #### Remplacement dans notre dataframe initiale des lignes associees aux especes non-matchees par celles de la nouvelle dataframe 
  less_NA_level <- which(all_species[, level_name[i - 1]] %in% ARG_level[, level_name[i - 1]])
  all_species[c(less_NA_level),] <- ARG_level
  NA_level <- is.na(all_species[, level_name[i]])
}

#### Traitement direct (hors join) de cas particulies d especes (principalement des 'bactérium') trop isolees pour faire l objet d'un join ####
ex1 <- which(all_species[, 'species'] == 'Bacillus bacterium')
all_species[ex1, c('Genus', 'Family', 'Order', 'Class', 'Phylum', 'Domain')] <-
  c('Bacillus', 'Bacillaceae', 'Bacillales', 'Bacilli', 'Firmicutes', 'Bacteria')

ex2 <- which(all_species[, 'species'] %in% c('Clostridia bacterium', 'Lachnospiraceae oral'))
all_species[ex2, 'Class'] <- 'Clostridia'
all_species[ex2, 'Phylum'] <- 'Firmicutes'
all_species[ex2, 'Domain'] <- 'Bacteria'

ex3 <- which(all_species[, 'species'] == 'Firmicutes bacterium')
all_species[ex3, 'Phylum'] <- 'Firmicutes'
all_species[ex3, 'Domain'] <- 'Bacteria'

ex4 <- which(all_species[, 'species'] == 'Lachnospiraceae oral')
all_species[ex4, 'Genus'] <- NA
all_species[ex4, 'Family'] <- 'Lachnospiraceae' 
all_species[ex4, 'Order'] <- 'Lachnospirales'

ex5 <- which(all_species[, 'species']  %in% c('Actinobacteria bacterium', 'Tissierellia bacterium', 'Bacteroidetes bacterium'))
all_species[ex5, 'Phylum'] <- str_replace(all_species[ex5, 'species'], '(.*) (.*)', '\\1')

#### Completion manuelle de la colonne 'Domain' (il n y en a que 1 : 'Bacteria') ####
ex6 <- is.na(all_species[, 'Domain']) # On isole les especes qui n ont pas pu etre matchees
na_species <- as.data.frame(unique(all_species[ex6, 'species'])) # On les conserve dans une liste au cas ou
all_species[ex6, 'Domain'] <- 'Bacteria' # On remplit la colonne 'Domain' pour toute ces especes 

#### Enregistrement de la dataframe slicee dans le fichier Sliced_ARG_Species.tsv ####
write.table(all_species, "W:/ninon-species/output/Output_M2/ARG/Dataframe/Sliced_ARG_Species.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
