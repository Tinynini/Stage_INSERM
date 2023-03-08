library(tidyverse)

#### Ouverture de bac120_taxonomy_r95.tsv (ou de bac120_taxonomy_r95_new.tsv pour la version alternative) & récupération des données ####
taxonomy <- read.csv('W:/ninon-species/data/bac120_taxonomy_r95.tsv', sep = ';', header = FALSE)
#taxonomy <- read.csv('W:/ninon-species/data/bac120_taxonomy_r95_new.tsv', sep = ';', header = FALSE) 
colnames(taxonomy) <- c('Occurrence', 'Domain', 'Phylum', 'Class', 'Order', 'Family', 'Genus', 'Species')
#colnames(taxonomy) <- c('sseqid', 'Domain', 'Phylum', 'Class', 'Order', 'Family', 'Genus', 'Species')

#### Modification de la nomenclature de la table de taxonomie en vue de son join avec nos propre données ####
for (i in 2:ncol(taxonomy)) # Suppression des préfix indiquant le niveau taxonomique (superflus car déjà indiqué par les nom de colonnes)
{
  taxonomy[,i] <- str_replace(taxonomy[,i], pattern = '(...)(.*)', replacement = "\\2")
}

for (j in 1:nrow(taxonomy)) # Suppression des suppléments de matricule en suffix chez les espèces 'sp' (également superflus)
{
  if (str_replace(taxonomy[j,'Species'], pattern = "(.*) (..)(.*)", replacement = "\\2") == 'sp')
  {
    taxonomy[j,'Species'] <- str_replace(taxonomy[j,'Species'], pattern = "(.*) (..)(.*)", replacement = "\\1\\ \\2")
  }
}

taxonomy %>% 
  arrange(Species) %>% 
  identity() -> taxonomy

taxonomy <- taxonomy[,-c(1)] # Pour la 1ère version uniquement
taxonomy <- rev(unique(taxonomy))

#### Elimination de certaines sous-classifications propres à l'étude dont est tirée cette table (et parasites pour la notre !) ####
for (k in 2:(ncol(taxonomy) - 1)) # On commence à 2 car la colonne des espèces n'a pas besoin d'être traitée 
{
  sub <- grep('(.*)_(.*)', taxonomy[, k])
  taxonomy[sub, k] <- str_replace(taxonomy[sub, k], '(.*)_(.*)', '\\1')
}

sub_espece1 <- grep('(.*)_(.*) (.*)', taxonomy[, 1])
taxonomy[sub_espece1, 1] <- str_replace(taxonomy[sub_espece1, 1], '(.*)_(.*) (.*)', '\\1\\ \\3')

sub_espece2 <- grep('(.*) (.*)_(.*)', taxonomy[, 1])
taxonomy[sub_espece2, 1] <- str_replace(taxonomy[sub_espece2, 1], '(.*) (.*)_(.*)', '\\1\\ \\2')

#taxonomy <- rev(unique(taxonomy)) # Pour la version alternative uniquement

#### Traitement préventif des données pour éviter la création de certains doublons lors du join ####
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

#### Enregistrement de la table de taxonomie dans le fichier Parsed_taxonomy.tsv (ou dans le fichier New_Parsed_taxonomy.tsv pour la version alternative) ####
write.table(taxonomy, "W:/ninon-species/output/Parsed_taxonomy.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
#write.table(taxonomy, "W:/ninon-species/output/New_Parsed_taxonomy.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
