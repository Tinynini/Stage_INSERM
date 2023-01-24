library(tidyverse)

#### Création d'une liste de tous les fichiers .tsv des dossier diamond_resfinder4 et diamond_resfinderFG ####
all_species4 <- list.files(path = 'W:/ninon-species/data/diamond_resfinder4', pattern = '.*.tsv', full.names = TRUE)
all_speciesFG <- list.files(path = 'W:/ninon-species/data/diamond_resfinderFG', pattern = '.*.tsv', full.names = TRUE)
all_species <- c(all_species4, all_speciesFG)

#### Création d'une liste de dataframe regroupant les données de la liste de fichier créée ci-dessus ####
n_species <- length(all_species)
all_names <- str_remove(basename(all_species), '.tsv')
species_list <- vector(mode = 'list', length = n_species)

for (i in 1:n_species)  
{
  curr_name <- all_names[i] 
  species <- read_tsv(file = all_species[i], col_names = FALSE)

  # Si le fichier traité est vide, on passe directement au suivant (== suppression des fichiers vides)
  if(nrow(species) == 0) 
  {
    next()
  }
  
  names(species) <- c('qseqid', 'sseqid', 'pident', 'qlen', 'slen', 'qcovhsp', 'length', 'mismatch', 'gapopen', 'qstart', 'qend', 'sstart', 'send', 'evalue', 'bitscore')
  
  # Suppression des doublons intra-espèces (== un même séquence d'un gène de résistances trouvée dans plusieurs séquences associées à la même espèce)
  species %>% 
    group_by(qseqid) %>% 
    arrange(pident, qcovhsp) %>%
    mutate(species = curr_name) %>% 
    slice_tail() -> species 
  
  species_list[[i]] <- species 
}

#### Transformation de la liste de dataframe en une seule dataframe & Ajout des colonne 'species' et 'shared_by' ####
out_df <- do.call(rbind, species_list) 

out_df %>% 
  group_by(qseqid) %>% 
  mutate(shared_by = n()) %>% 
  identity() -> out_df 

table(out_df$species) 
table(out_df$shared_by) 

Species <- unlist(out_df['species'])

for (j in 1:nrow(out_df)) # Inversion des 2 parties de nom d'espèce pour les espèces 'UNVERIFIED_ORG' pour avoir la bonne nomenclatuture
{
  if (startsWith(Species[j], 'UNV') == TRUE)
  {
    out_df[j,'species'] <- str_replace(out_df[j,'species'], pattern = "(.*)_(.*)_(.*)", replacement = "\\3\\_\\1\\_\\2.")
  }
}

#### Enregistrement de la dataframe dans le fichier all_species.tsv ####
write.table(out_df, "W:/ninon-species/output/all_species.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)