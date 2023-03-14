library(tidyverse)

Parsed_taxonomy <- read_tsv('W:/ninon-species/output/Table_taxonomie/Parsed_taxonomy.tsv')
Parsed_taxonomy <- Parsed_taxonomy[-c(2051, 4092, 9605),]

level_name <- unlist(colnames(Parsed_taxonomy[, c(1:4)]))
level_name[1] <- 'species'

suffix <- c('', '(.*) (bacterium)', '(.*)(ceae) (bacterium)', '(.*)(ales) (bacterium)')
cond <- c('', FALSE, TRUE, TRUE)

all_species <- read_tsv('W:/ninon-species/output/Output_M2/Dataframe/sliced_all_species_clust.tsv') %>%
  as.data.frame()

all_species[, 'species'] <- str_replace(all_species[, 'species'], pattern = '(.*)(_)(.*)', replacement = "\\1\\ \\3")
Species <- unlist(all_species['species'])

for (j in 1:nrow(all_species))
{
  if (endsWith(Species[j], 'ORG-.') == TRUE)
  {
    all_species[j,'species'] <- str_replace(all_species[j,'species'], pattern = "(.*)_(.*) (.*)(..)", replacement = "\\1\\ \\2\\_\\3")
  }
}

err <- grep('(Bacterium) (.*)', all_species[, 'species'])
all_species[err, 'species'] <- str_replace(all_species[err, 'species'], '(Bacterium) (.*)', '\\2\\ \\1')

all_species %>%
  arrange(qseqid) %>%
  identity() -> all_species

all_species <- all_species[, c('qseqid', 'Centroid', 'shared_by', 'pident', 'qcovhsp', 'sseqid', 'species')]
all_species <- left_join(all_species, Parsed_taxonomy, by = c('species' = 'Species'))
na_species <- as.data.frame(unique(all_species[is.na(all_species[, 'Genus']), 'species']))

Genus_cleaner <- function(df, level, doublon, ref)
{
  double1 <- which(df[, level] %in% doublon)
  double2 <- which(df[c(double1), 'Family'] != ref)
  ARG_double <- df[c(double1),]
  df[c(double1),] <- ARG_double[-c(double2),]
  
  df <- unique(df)
}

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

NA_level <- is.na(all_species[, level_name[2]])

for (i in 2:4)
{
  Parsed_taxonomy <- Parsed_taxonomy[,-c(1)]

  l <- 1

  for (k in 1:nrow(all_species))
  {
    if (NA_level[k] == TRUE & grepl(suffix[i], all_species[k, 'species']) == cond[i])
    {
      all_species[k, level_name[i]] <- str_replace(all_species[k, 'species'], '(.*) (.*)', '\\1')
      l <- l + 1
    }
  }

  ARG_level <- as.data.frame(all_species[c(NA_level), c(1:(i + 6))])
  colnames(ARG_level) <- colnames(all_species[, c(1:(i + 6))])
  ARG_level <- left_join(ARG_level, Parsed_taxonomy, by = NULL)

  ARG_level <- unique(ARG_level)

  if (i == 2)
  {
    ARG_level <- Genus_cleaning(ARG_level)
  }

  less_NA_level <- which(all_species[, level_name[i - 1]] %in% ARG_level[, level_name[i - 1]])
  all_species[c(less_NA_level),] <- ARG_level
  NA_level <- is.na(all_species[, level_name[i]])
}

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

na_species <- as.data.frame(unique(all_species[is.na(all_species[, 'Domain']), 'species']))

write.table(all_species, "W:/ninon-species/output/Output_M2/Dataframe/Sliced_ARG_Species.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
