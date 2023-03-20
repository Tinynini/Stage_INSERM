library(tidyverse)

#### Ouverture de de Sliced_ARG_Species.tsv & recuperation des donnees ####
taxo <- read_tsv('W:/ninon-species/output/Output_M2/ARG/Dataframe/Sliced_ARG_Species.tsv') %>% 
  as.data.frame()

#### On genere 6 nouvelles colonnes des partages de centroides du niveau 'species' au niveau 'Phylum' ####
# N.B. : Le niveau 'Domain' n est pas traite car cette etude ne porte que sur le domaine des 'bacteria' (== bacterie)
taxo %>%
  arrange(Centroid) %>%
  group_by(Centroid) %>%
  mutate(species_shared_by = length(unique(species))) %>% # Partages inter-especes
  mutate(genus_shared_by = length(unique(Genus))) %>% # Partages inter-genus
  mutate(family_shared_by = length(unique(Family))) %>% # Partages inter-familles
  mutate(order_shared_by = length(unique(Order))) %>% # Partages inter-ordres
  mutate(class_shared_by = length(unique(Class))) %>% # Partages inter-classes
  mutate(phylum_shared_by = length(unique(Phylum))) %>% # Partages inter-phyla (N.B. : phyla == pluriel de phylum)
  identity() -> taxo

taxo <- taxo[, -3] # On supprime la colonne des 'shared_by' car elle est identique a celle des 'species_shared_by' et donc redondante

#### Enregistrement de la dataframe slicee dans le fichier Sliced_Taxo_Result.tsv ####
write.table(taxo, "W:/ninon-species/output/Output_M2/ARG/Dataframe/Sliced_Taxo_Result.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)

#### Slice de la dataframe sur les centroides de facon a n avoir plus que une seule occurrence par centroid ####
taxo %>% 
  ungroup() %>% 
  group_by(Centroid) %>%
  arrange(pident, qcovhsp) %>%
  slice_tail() -> taxo_small

# On rearrange les données en vue des plots
taxo_small %>% 
  arrange(phylum_shared_by, class_shared_by, order_shared_by, family_shared_by, genus_shared_by, species_shared_by) %>%
  identity() -> taxo_small

generate_plot_fr <- function(level_share, level_name)
{
  title_start = "Nombres d'occurrences des valeurs de partages inter-"

  level_plot <- ggplot(level, aes(level_share)) + geom_histogram(bins = (max(level_share)*2 - 1))
  title <- str_glue("{title_start}{level_name}")
  plot(level_plot + ggtitle(label = title) + xlab("valeurs des partages") + ylab("Nombres d'occurences"))
}

generate_plot_en <- function(level_share, level_name)
{
  title_start = "Inter-"
  title_end = " sharing value occurences"
  
  level_plot <- ggplot(level, aes(level_share)) + geom_histogram(bins = (max(level_share)*2 - 1))
  title <- str_glue("{title_start}{level_name}{title_end}")
  plot(level_plot + ggtitle(label = title) + xlab("sharing values") + ylab("Number of occurences"))
}

level <- as.data.frame(taxo_small[, c(13:18)])
level_name <- unlist(colnames(taxo_small[, c(6:11)]))

for (i in 1:6)
{
  level_share <- level[, i]
  generate_plot_fr(level_share, level_name[i])
  generate_plot_en(level_share, level_name[i])
}
