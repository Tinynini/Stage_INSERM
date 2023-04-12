library(tidyverse)

#### Ouverture de Parsed_taxonomy.tsv et de Sliced_all_species_clust.tsv & recuperation des donnees ####
Parsed_taxonomy <- read_tsv('W:/ninon-species/output/Table_taxonomie/Parsed_taxonomy.tsv')
Parsed_taxonomy <- Parsed_taxonomy[-c(2051, 4092, 9605),] # Suppression preventive de certaine lignes de la table de taxonomie pour eviter l apparition de certains doublons 

all_species <- read_tsv('W:/ninon-species/output/Output_M2/ARG/Dataframe/sliced_all_species_clust.tsv') %>%
  as.data.frame()

#### Fonction servant a effectuer un traitement supplementaire pour les noms d especes qui matchent 'pattern_1' ####
special_treat <- function(df, j, pattern_1, pattern_2, replacement)
{
  if (grepl(pattern_1, df[j,'species']) == TRUE)
  {
    df[j,'species'] <- str_replace(df[j,'species'], pattern_2, replacement)
  }
  
  return(df)
}

#### Fonction servant a supprimer de maniere systematique certain types de doublons post-joint ####
Genus_cleaner <- function(df, level, doublon, ref)
{
  double1 <- which(df[, level] %in% doublon)
  double2 <- which(df[c(double1), 'Family'] != ref)
  gene_double <- df[c(double1),]
  df[c(double1),] <- gene_double[-c(double2),]
  
  df <- unique(df)
}

#### Fonction (utilisant celle ci-avant) servant a gerer l ensemble des doublon crees lors du join au niveau des genus ####
Genus_cleaning <- function(df)
{
  df <- Genus_cleaner(df, 'species', c('Clostridium aldenense', 'Clostridium clostridioforme'), 'Lachnospiraceae')
  df <- Genus_cleaner(df, 'species', 'Clostridium difficile', 'Peptostreptococcaceae')
  df <- Genus_cleaner(df, 'species', 'Clostridium phoceensis', 'Acutalibacteraceae')
  df <- Genus_cleaner(df, 'Genus', 'Ruminococcus', 'Lachnospiraceae')
  df <- Genus_cleaner(df, 'Genus', 'Eubacterium', 'Eubacteriaceae')
  df <- Genus_cleaner(df, 'Genus', 'Mycoplasma', 'Mycoplasmataceae')
  
  double1 <- grep('Clostridium', df[, 'Genus'])
  gene_Clos <- df[c(double1),]

  double2 <- which(gene_Clos[, 'species'] %in% c('Clostridium aldenense', 'Clostridium clostridioforme', 'Clostridium difficile', 'Clostridium phoceensis'))
  gene_Target <- gene_Clos[-c(double2),]

  df <- Genus_cleaner(df, 'species', gene_Target[, 'species'], 'Clostridiaceae')

  df <- unique(df)
}

#### Fonction servant a recuperer manuellement la taxonomie des especes qui matchent 'wanted' ####
except_treat <- function(df, wanted, level_1, level_2, level_3, rep_1, rep_2, rep_3)
{ # On est oblige de traiter chaque niveau d interet separement autrement un decalage systematique a lieu a chaque nouvelle ligne traitee
  ex <- which(df[, 'species'] %in% wanted)
  df[ex, level_1] <- rep_1
  df[ex, level_2] <- rep_2
  df[ex, level_3] <- rep_3
  # On prevoit donc le traitement de 3 niveaux distincts (on n a pas besoin de plus heureusement)
  return(df)
} 

#### Preparation des donnees en vue d un 1er join au niveau des especes ####
# On reordonne les colonnes en vue du join en ne gardant que celles dont on a besoin pour la suite  
all_species <- all_species[, c('qseqid', 'Centroid', 'shared_by', 'pident', 'qcovhsp', 'sseqid', 'species')]
# On modifie la nomenclature des noms d especes en vue du join 
all_species[, 'species'] <- str_replace(all_species[, 'species'], pattern = '(.*)(_)(.*)', replacement = "\\1\\ \\3")

for (j in 1:nrow(all_species)) # Certains noms d especes necessitent un traitement supplementaire
{
  all_species <- special_treat(all_species, j, 'ORG-.', "(.*)_(.*) (.*)(..)", "\\1\\ \\2\\_\\3")
  all_species <- special_treat(all_species, j, 'symbiont', "(.*) (.*)", "\\2\\ \\1")
  all_species <- special_treat(all_species, j, 'Bacterium', "(.*) (.*)", "\\2\\ \\1")
}

#### 1er join au niveau des especes --> consequence : ajout de 6 nouvelles colonnes ('Genus' a 'Domain') ####
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
  gene_level <- as.data.frame(all_species[c(NA_level), c(1:(i + 6))])
  colnames(gene_level) <- colnames(all_species[, c(1:(i + 6))])
  gene_level <- left_join(gene_level, Parsed_taxonomy, by = NULL) # Join au niveau i
  gene_level <- unique(gene_level)
  
  # Traitement visant a supprimer les nombreux doublons generes par le join au niveau des genus ####
  if (i == 2)
  {
    gene_level <- Genus_cleaning(gene_level)
  }

  # Remplacement dans notre dataframe initiale des lignes associees aux especes non-matchees par celles de la nouvelle dataframe 
  less_NA_level <- which(all_species[, level_name[i - 1]] %in% gene_level[, level_name[i - 1]])
  all_species[c(less_NA_level),] <- gene_level
  NA_level <- is.na(all_species[, level_name[i]])
}

#### Traitement direct (hors join) de cas particuliers d especes (principalement des 'bactérium') trop isolees pour faire l objet d'un join ####
# N.B. : On peut traiter plusieurs niveaux a la fois pour ce 1er traitement parce qu il ne concerne qu une seule ligne (== on n a pas le probleme du decalage a chaque nouvelle ligne)
all_species <- except_treat(all_species, 'Bacillus bacterium', c('Genus', 'Family', 'Order', 'Class'), 'Phylum', 'Domain', c('Bacillus', 'Bacillaceae', 'Bacillales', 'Bacilli') , 'Firmicutes', 'Bacteria')
all_species <- except_treat(all_species, 'Lachnospiraceae oral', 'Genus', 'Family', 'Order', NA, 'Lachnospiraceae', 'Lachnospirales')
all_species <- except_treat(all_species, c('Clostridia bacterium', 'Lachnospiraceae oral'), 'Class', 'Phylum', 'Domain', 'Clostridia', 'Firmicutes', 'Bacteria')
all_species <- except_treat(all_species, 'Firmicutes bacterium', 'Phylum', 'Phylum', 'Domain', 'Firmicutes' , 'Firmicutes', 'Bacteria')

# Traitement de 3 especes 'bacterium' ne pouvant etre fait avec la fonction except_treat()
ex1 <- which(all_species[, 'species']  %in% c('Actinobacteria bacterium', 'Tissierellia bacterium', 'Bacteroidetes bacterium'))
all_species[ex1, 'Phylum'] <- str_replace(all_species[ex1, 'species'], '(.*) (.*)', '\\1')

# Completion manuelle de la colonne 'Domain' (il n y en a qu un : 'Bacteria')
ex2 <- is.na(all_species[, 'Domain']) # On isole les especes qui n ont pas pu etre matchees
na_species <- as.data.frame(unique(all_species[ex2, 'species'])) # On les conserve dans une liste au cas ou
all_species[ex2, 'Domain'] <- 'Bacteria' # On remplit la colonne 'Domain' pour toute ces especes 

#### Enregistrement de la dataframe slicee dans le fichier Sliced_ARG_Species.tsv ####
write.table(all_species, "W:/ninon-species/output/Output_M2/ARG/Dataframe/Sliced_ARG_Species.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
