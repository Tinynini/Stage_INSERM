#library(tidyverse)

#########################################################################################
# Ninon ROBIN -- ninon.robin@inserm.fr                                                  #
# Utilite == generer les colonnes des partages inter-especes aux 6 niveaux taxonomiques #
# et les histogrammes des nombres d occurrence de valeurs de partages a chaque niveaux  #
# Input == sliced_all_species_taxo.tsv                                                  #
# Output == Sliced_Taxo_Result.tsv et les 6 histogrammes (en FR et EN)                  #
#########################################################################################

#### Ouverture de sliced_all_species_taxo.tsv & recuperation des donnees ####
taxo <- read_tsv('W:/ninon-species/output/Output_M2/ARG/Dataframe/sliced_all_species_taxo.tsv', col_types = "ccdddccccccc") %>%
  as.data.frame()

#### On genere 6 nouvelles colonnes des partages de genes du niveau 'species' au niveau 'Phylum' ####
taxo %>% # Pour chaque partages de chaque centroids on regarde le nombre de representants distincts de chacuns des 6 niveaux taxonomiques
  arrange(Centroid) %>%
  group_by(Centroid) %>%
  mutate(species_shared_by = length(unique(species))) %>% # Partages inter-especes
  mutate(genus_shared_by = length(unique(Genus))) %>% # Partages inter-genus
  mutate(family_shared_by = length(unique(Family))) %>% # Partages inter-familles
  mutate(order_shared_by = length(unique(Order))) %>% # Partages inter-ordres
  mutate(class_shared_by = length(unique(Class))) %>% # Partages inter-classes
  mutate(phylum_shared_by = length(unique(Phylum))) %>% # Partages inter-phyla (N.B. : phyla == pluriel de phylum)
  identity() -> taxo

taxo <- taxo[, -3] # On supprime la colonne 'shared_by' car elle est identique a 'species_shared_by' et donc redondante

#### Enregistrement de la dataframe slicee dans le fichier Sliced_Taxo_Result.tsv ####
write.table(taxo, "W:/ninon-species/output/Output_M2/ARG/Dataframe/Sliced_Taxo_Result.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)

#### Slice de la dataframe sur les partages inter-especes des centroides de facon a n avoir plus qu une seule occurrence de chaques partages par centroides ####
taxo %>% 
  ungroup() %>% 
  group_by(Centroid) %>%
  arrange(pident, qcovhsp) %>%
  slice_tail() -> taxo_small
# On rearrange les données en vue des plots
taxo_small %>% 
  arrange(phylum_shared_by, class_shared_by, order_shared_by, family_shared_by, genus_shared_by, species_shared_by) %>%
  identity() -> taxo_small

#### histogrammes des nombres d occurrences des valeurs de partage aux 6 niveaux taxonomiques etudies ####
# Fonction pour generer les plots avec le titre et les labels en francais
generate_plot_fr <- function(level_share, level_name)
{
  start <- 'Taxo_'
  end <- '_fr.png'
  title_start <- "Nombres d'occurrences des valeurs de partages inter-"
  path = "W:/ninon-species/output/Output_M2/ARG/Plot/Taxo_plot/FR"
  title <- str_glue("{title_start}{level_name}") # Le titre de l histogramme est definit par une variable
  ggplot(level, aes(level_share)) + geom_histogram(bins = max(level_share)*2 - 1) + ggtitle(label = title) + xlab("Valeurs des partages") + ylab("Nombres d'occurences") 
  ggsave(str_glue("{start}{level_name}{end}"), plot = last_plot(), device = "png", path = path, width = 16, height = 8.47504)
}
# Fonction pour generer les plots avec le titre et les labels en anglais
generate_plot_en <- function(level_share, level_name)
{
  start <- 'Taxo_'
  end <- '_en.png'
  title_start <- "Inter-"
  title_end <- " sharing value occurences"
  path = "W:/ninon-species/output/Output_M2/ARG/Plot/Taxo_plot/EN"
  title <- str_glue("{title_start}{level_name}{title_end}") # Le titre de l histogramme est definit par une variable
  ggplot(level, aes(level_share)) + geom_histogram(bins = max(level_share)*2 - 1) + ggtitle(label = title) + xlab("Sharing values") + ylab("Number of occurences") 
  ggsave(str_glue("{start}{level_name}{end}"), plot = last_plot(), device = "png", path = path, width = 16, height = 8.47504)
}

level <- as.data.frame(taxo_small[, c(12:17)]) # On extrait le contenu des colonnes associees aux partages au 6 niveaux taxonomiques etudies
level_name <- unlist(colnames(taxo_small[, c(6:11)])) # On extrait aussi leurs labels pour pouvoir travailler a un niveau donne plus facilement

for (i in 1:6) # Permet de parcourir les 6 niveaux taxonomique (d especes a phylum)
{
  level_share <- level[, i] # On extrai la colonne associe au niveau i
  generate_plot_fr(level_share, level_name[i]) # On lui applique la fonction generate_plot_fr()
  generate_plot_en(level_share, level_name[i]) # On lui applique la fonction generate_plot_en()
}
