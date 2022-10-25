library(tidyverse)

Parsed_taxonomy <- read_tsv('W:/ninon-species/output/Parsed_taxonomy.tsv') 
Parsed_taxonomy <- Parsed_taxonomy[-c(2051, 4092, 9605),]

level_name <- unlist(colnames(Parsed_taxonomy[, c(1:4)]))
level_name[1] <- 'species'

suffix <- c('', '', 'ceae', 'ales')

all_species <- read_tsv('W:/ninon-species/output/all_species_clust.tsv') %>%
  #all_species <- read_tsv('W:/ninon-species/output/sliced_all_species_clust.tsv') %>%
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

for (i in 1:4)
{
  NA_level <- is.na(all_species[, level_name[i]])
  l <- 1

  for (k in 1:nrow(all_species))
  {
    if (is.null(NA_level) == FALSE) ## Problem avec suffix, utiliser fonctions str à la place de grepl ??
    {
      if (NA_level[k] == TRUE & grepl("(.*)(suffix[i]) (bacterium)", all_species[k, level_name[i - 1]]) == FALSE)
      {
        all_species[k, level_name[i]] <- str_replace(all_species[k, level_name[i - 1]], '(.*) (.*)', '\\1')
        l <- l + 1
      }
    }
  }

  ARG_level <- as.data.frame(all_species[c(NA_level),])
  colnames(ARG_level) <- colnames(all_species)
  ARG_level <- left_join(ARG_level, Parsed_taxonomy, by = c(level_name[i] = colnames(Parsed_taxonomy[, 1])))

  if (i > 1)
  {
    less_NA_level <- which(all_species[, level_name[i - 1]] %in% ARG_level[, level_name[i - 1]])
    all_species[c(less_NA_level),] <- ARG_level
  }

  else
  {
    all_species <- ARG_level
  }

  Parsed_taxonomy <- Parsed_taxonomy[,-c(1)]
}

#### Traitements Genus non automatisables ?? ####

# all_species <- unique(all_species)
# 
# double1 <- which(all_species[, 'species'] %in% c('Clostridium aldenense', 'Clostridium clostridioforme'))
# double2 <- which(all_species[c(double1), 'Family'] != 'Lachnospiraceae')
# ARG_double <- all_species[c(double1),]
# all_species[c(double1),] <- ARG_double[-c(double2),]
# 
# all_species <- unique(all_species)
# 
# double3 <- which(all_species[, 'species'] == 'Clostridium difficile')
# double4 <- which(all_species[c(double3), 'Family'] != 'Peptostreptococcaceae')
# ARG_double2 <- all_species[c(double3),]
# all_species[c(double3),] <- ARG_double2[-c(double4),]
# 
# all_species <- unique(all_species)
# 
# double5 <- which(all_species[, 'species'] == 'Clostridium phoceensis')
# double6 <- which(all_species[c(double5), 'Family'] != 'Acutalibacteraceae')
# ARG_double3 <- all_species[c(double5),]
# all_species[c(double5),] <- ARG_double3[-c(double6),]
# 
# all_species <- unique(all_species)
# 
# double <- grep('Clostridium', all_species[, 'genus'])
# ARG_Clos <- all_species[c(double),]
# 
# double7 <- which(ARG_Clos[, 'species'] %in% c('Clostridium aldenense', 'Clostridium clostridioforme', 'Clostridium difficile', 'Clostridium phoceensis'))
# ARG_Target <- ARG_Clos[-c(double7),]
# double8 <- which(all_species[, 'species'] %in% ARG_Target[, 'species'])
# double9 <- which(all_species[c(double8), 'Family'] != 'Clostridiaceae')
# ARG_double4 <- all_species[c(double8),]
# all_species[c(double8),] <- ARG_double4[-c(double9),]
# 
# all_species <- unique(all_species)
# 
# double10 <- which(all_species[, 'genus'] == 'Ruminococcus')
# double11 <- which(all_species[c(double10), 'Family'] != 'Ruminococcaceae')
# ARG_double5 <- all_species[c(double10),]
# all_species[c(double10),] <- ARG_double5[-c(double11),]
# 
# all_species <- unique(all_species)
# 
# double12 <- which(all_species[, 'genus'] == 'Eubacterium')
# double13 <- which(all_species[c(double12), 'Family'] != 'Eubacteriaceae')
# ARG_double6 <- all_species[c(double12),]
# all_species[c(double12),] <- ARG_double6[-c(double13),]
# 
# all_species <- unique(all_species)
# 
# double14 <- which(all_species[, 'genus'] == 'Mycoplasma')
# double15 <- which(all_species[c(double14), 'Family'] != 'Mycoplasmataceae')
# ARG_double7 <- all_species[c(double14),]
# all_species[c(double14),] <- ARG_double7[-c(double15),]
# 
# all_species <- unique(all_species)
# 
# #### cas post-ordre traités manuellement ####
# 
# ex1 <- which(all_species[, 'species'] == 'Bacillus bacterium')
# all_species[ex1, c('Genus', 'Family', 'Order', 'Class', 'Phylum', 'Domain')] <-
#   c('Baccilus', 'Bacillaceae', 'Bacillales', 'Bacilli', 'Firmicutes', 'Bacteria')
# 
# ex2 <- which(all_species[, 'species'] == 'Clostridia bacterium')
# all_species[ex2, 'Class'] <- 'Clostridia'
# all_species[ex2, 'Phylum'] <- 'Firmicutes'
# all_species[ex2, 'Domain'] <- 'Bacteria'
# 
# ex3 <- which(all_species[, 'species'] == 'Firmicutes bacterium')
# all_species[ex3, 'Phylum'] <- 'Firmicutes'
# all_species[ex3, 'Domain'] <- 'Bacteria'
# 
# na_species <- as.data.frame(unique(all_species[is.na(all_species[, 'Domain']), 'species']))

# write.table(all_Species, "W:/ninon-species/output/Total_ARG_Species.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
# #write.table(all_Species, "W:/ninon-species/output/Sliced_ARG_Species.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)