library(tidyverse)
library(ggtree)

#### Ouverture de Final_ARG_species.tsv (ou de Final_New_ARG_species.tsv) & recuperation des donnees ####
taxo <- read_tsv('W:/ninon-species/output/Output_M1/Dataframe/Final_ARG_species.tsv') %>% 
#taxo <- read_tsv('W:/ninon-species/output/Output_M1/Dataframe/Final_New_ARG_species.tsv') %>% 
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

#### Enregistrement de la dataframe complete dans le fichier Taxo_result.tsv (ou de celle slicee dans le fichier New_Taxo_result.tsv) ####
write.table(taxo, "W:/ninon-species/output/Output_M1/Dataframe/Taxo_result.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
#write.table(taxo, "W:/ninon-species/output/Output_M1/Dataframe/New_Taxo_result.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)

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

#### Plot des histogrames des partages des centroides du niveau 'species' au niveau 'phylum' ####
species_share <- taxo_small['species_shared_by']
species_num <- nrow(unique(species_share)) # Donne le nombre de barre que doit contenir l histogramme
splot <- ggplot(species_share, aes(species_shared_by)) + geom_histogram(bins = (max(species_share)*2 - 1))
splot + ggtitle("Nombres d'occurrences des valeurs de partages inter-espèces") + xlab("Valeurs des partages") + ylab("Nombres d'occurences")

genus_share <- taxo_small['genus_shared_by']
genus_num <- nrow(unique(genus_share)) # Donne le nombre de barre que doit contenir l histogramme
gplot <- ggplot(genus_share, aes(genus_shared_by)) + geom_histogram(bins = (max(genus_share)*2 - 1))
gplot + ggtitle("Nombres d'occurrences des valeurs de partages inter-genres") + xlab("Valeurs des partages") + ylab("Nombres d'occurences")

family_share <- taxo_small['family_shared_by']
family_num <- nrow(unique(family_share)) # Donne le nombre de barre que doit contenir l histogramme
fplot <- ggplot(family_share, aes(family_shared_by)) + geom_histogram(bins = (max(family_share)*2 - 1))
fplot + ggtitle("Nombres d'occurrences des valeurs de partages inter-familles") + xlab("Valeurs des partages") + ylab("Nombres d'occurences")

order_share <- taxo_small['order_shared_by']
order_num <- nrow(unique(order_share)) # Donne le nombre de barre que doit contenir l histogramme
oplot <- ggplot(order_share, aes(order_shared_by)) + geom_histogram(bins = (max(order_share)*2 - 1))
oplot + ggtitle("Nombres d'occurrences des valeurs de partages inter-ordres") + xlab("Valeurs des partages") + ylab("Nombres d'occurences")

class_share <- taxo_small['class_shared_by']
class_num <- nrow(unique(class_share)) # Donne le nombre de barre que doit contenir l histogramme
cplot <- ggplot(class_share, aes(class_shared_by)) + geom_histogram(bins = (max(class_share)*2 - 1))
cplot + ggtitle("Nombres d'occurrences des valeurs de partages inter-classes") + xlab("Valeurs des partages") + ylab("Nombres d'occurences")

phylum_share <- taxo_small['phylum_shared_by']
phylum_num <- nrow(unique(phylum_share)) # Donne le nombre de barre que doit contenir l histogramme
pplot <- ggplot(phylum_share, aes(phylum_shared_by)) + geom_histogram(bins = (max(phylum_share)*2 - 1))
pplot + ggtitle("Nombres d'occurrences des valeurs de partages inter-phyla") + xlab("Valeurs des partages") + ylab("Nombres d'occurences")
