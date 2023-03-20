library(tidyverse)

#### Ouverture de bac120_taxonomy_r95.tsv et de bac120_taxonomy_r95_new.tsv & recuperation des donnees ####
taxonomy_V1 <- read.csv('W:/ninon-species/data/bac120/bac120_taxonomy_r95.tsv', sep = ';', header = FALSE)
taxonomy_V2 <- read.csv('W:/ninon-species/data/bac120/bac120_taxonomy_r95_new.tsv', sep = ';', header = FALSE) 
colnames(taxonomy_V1) <- c('Occurrence', 'Domain', 'Phylum', 'Class', 'Order', 'Family', 'Genus', 'Species')
colnames(taxonomy_V2) <- c('sseqid', 'Domain', 'Phylum', 'Class', 'Order', 'Family', 'Genus', 'Species')

#### Modification de la nomenclature du join avec nos propre donnees ####
nomenclature_cleaner <- function(taxonomy)
{
  for (i in 2:ncol(taxonomy)) # Suppression des prefix indiquant le niveau taxonomique (superflus car deja indique par les noms de colonnes)
  {
    taxonomy[,i] <- str_replace(taxonomy[,i], pattern = '(...)(.*)', replacement = "\\2")
  }
  
  for (j in 1:nrow(taxonomy)) # Suppression des supplements de matricule en suffix chez les especes 'sp' (egalement superflus)
  {
    if (str_replace(taxonomy[j,'Species'], pattern = "(.*) (..)(.*)", replacement = "\\2") == 'sp')
    {
      taxonomy[j,'Species'] <- str_replace(taxonomy[j,'Species'], pattern = "(.*) (..)(.*)", replacement = "\\1\\ \\2")
    }
  }
  
  taxonomy %>% 
    arrange(Species) %>% 
    identity() -> taxonomy
}

#### Elimination de certaines sous-classifications propres a l'etude dont est tiree cette table (et parasites pour la notre !) ####
sub_class_cleaner <- function(taxonomy)
{
  taxonomy <- rev(unique(taxonomy))
  
  for (k in 2:(ncol(taxonomy) - 1)) # On commence a 2 car la colonne des especes n a pas besoin d etre traitee 
  {
    sub <- grep('(.*)_(.*)', taxonomy[, k])
    taxonomy[sub, k] <- str_replace(taxonomy[sub, k], '(.*)_(.*)', '\\1')
  }
  
  sub_espece1 <- grep('(.*)_(.*) (.*)', taxonomy[, 1])
  taxonomy[sub_espece1, 1] <- str_replace(taxonomy[sub_espece1, 1], '(.*)_(.*) (.*)', '\\1\\ \\3')
  
  sub_espece2 <- grep('(.*) (.*)_(.*)', taxonomy[, 1])
  taxonomy[sub_espece2, 1] <- str_replace(taxonomy[sub_espece2, 1], '(.*) (.*)_(.*)', '\\1\\ \\2')

  taxonomy <- unique(taxonomy)
}

#### Traitement preventif pour eviter la creation de certains doublons lors du join ####
prev_doublon_cleaner <- function(taxonomy)
{
  sub2 <- grep('Bacillus', taxonomy[, 'Genus'])
  taxonomy[sub2,'Family'] <- 'Bacillaceae'
  taxonomy[sub2, 'Order'] <- 'Bacillales'
  
  sub3 <- grep('Ruminococcus sp', taxonomy[, 'Species'])
  taxonomy[sub3, 'Family'] <- 'Ruminococcaceae'
  taxonomy[sub3, 'Order'] <- 'Oscillospirales'
  
  sub4 <- grep('Clostridium sp', taxonomy[, 'Species'])
  taxonomy[sub4, 'Family'] <- 'Clostridiaceae'
  taxonomy[sub4, 'Order'] <- 'Clostridiales'
  
  sub5 <- grep('Eubacterium sp', taxonomy[, 'Species'])
  taxonomy[sub5, 'Family'] <- 'Lachnospiraceae'
  taxonomy[sub5, 'Order'] <- 'Lachnospirales'
  
  taxonomy <- unique(taxonomy)
}

#### Main ####
taxonomy_V1 <- nomenclature_cleaner(taxonomy_V1)
taxonomy_V2 <- nomenclature_cleaner(taxonomy_V2)

taxonomy_V1 <- taxonomy_V1[,-c(1)]

taxonomy_V1 <- sub_class_cleaner(taxonomy_V1)
taxonomy_V2 <- sub_class_cleaner(taxonomy_V2)

taxonomy_V2 <- unique(taxonomy_V2)

taxonomy_V1 <- prev_doublon_cleaner(taxonomy_V1)
taxonomy_V2 <- prev_doublon_cleaner(taxonomy_V2)

#### Enregistrement des 2 versions de la table de taxonomie dans les fichier Parsed_taxonomy.tsv et New_Parsed_taxonomy.tsv ####
write.table(taxonomy_V1, "W:/ninon-species/output/Table_taxonomie/Parsed_taxonomy.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
write.table(taxonomy_V2, "W:/ninon-species/output/Table_taxonomie/New_Parsed_taxonomy.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
