library(tidyverse)
library(tidytree)
library(ape)

#### Ouverture de bac120_r95.tree et de New_Parsed_taxonomy.tsv et de Taxo_result.tsv (ou de New_Taxo_result.tsv) & recuperation des donnees ####
tree <- read.tree('W:/ninon-species/data/bac120_r95.tree')
tree_df <- as_tibble(tree) # On passe au format tibble plus pratique a manipuler

all_species <- read_tsv('W:/ninon-species/output/Taxo_result.tsv') %>%
#all_species <- read_tsv('W:/ninon-species/output/New_Taxo_result.tsv') %>% 
  as.data.frame()

# On extrait les colonnes 'species' et 'species_shared_by' (qui fait juste office de marqueur) de la dataframe
uni_species <- as.data.frame(sort(unique(all_species[, 'species']))) 
colnames(uni_species) <- 'species'
uni_species <- unique(left_join(uni_species, all_species[, c('species', 'species_shared_by')], by = c('species' = 'species')))

taxo <- read_tsv('W:/ninon-species/output/New_Parsed_taxonomy.tsv') %>% 
  as.data.frame()

# On extrait les colonnes 'sseqid' et 'Species' de la table de taxonomie
small_taxo <- taxo[, c(1, 8)]

#### Join de l abre avec les especes de la table de taxonomie (== remplacer les labels par les noms d especes associes) ####
taxo_tree <- left_join(tree_df, small_taxo, by = c('label' = 'sseqid')) # On join sur les labels de sequences bacteriennes
taxo_tree[1:Ntip(tree), 'label'] <- taxo_tree[1:Ntip(tree), 'Species'] # On remplace les labels de tips (pas de nodes) par les noms d especes associes 
taxo_tree <- taxo_tree[, -5]

Label <- taxo_tree[1:Ntip(tree),] # On travaille sur les labels de tips uniquement 
labels <- Label

labels %>%
  arrange(label, parent) %>%
  group_by(label) %>% 
  slice(1) -> labels

labels <- rbind(labels)

Label %>%
  arrange(node) %>%
  identity() -> Label

labels %>%
  arrange(node) %>%
  identity() -> labels
# On extrait les tips qui constituent des doublons
tips <- which((Label[, 'node'] %>% pull()) %in% (labels[, 'node'] %>% pull()) == FALSE) 

new_tree <- as.phylo(taxo_tree) # On passe au format phylo pour pouvoir pruner l arbre
new_tree <- drop.tip(new_tree, tips) # On prune l arbre en supprimant les tips associes aux doublons
taxo_tree <- as_tibble(new_tree) # On passe au format tibble plus pratique a manipuler

#### Join de l abre avec les especes de notre dataframe (== pruner l arbre en ne gardant que les especes presentes dans notre dataframe) ####
phylo_tree <- left_join(taxo_tree, uni_species, by = c('label' = 'species')) # On join sur les noms d especes
n_tips <- nrow(phylo_tree) - Nnode(new_tree)

na_label <- is.na(phylo_tree[1:n_tips, 'species_shared_by']) # On extrait les labels des tips matchés lors du join
species <- which(na_label == FALSE)

phylo_tree[species, 'species_shared_by'] <- 1 # On standardise la valeur de la colonne 'species_shared_by' pour ces tips 
phylo_tree <- unique(phylo_tree) # On supprime les doublons

na_label <- is.na(phylo_tree[1:Ntip(new_tree), 'species_shared_by']) # On extrait les labels des tips non-matches
na_species <- which(na_label == TRUE)

next_tree <- as.phylo(phylo_tree) # On passe au format phylo pour pouvoir pruner l arbre
next_tree <- drop.tip(next_tree, na_species) # On prune l arbre en supprimant les tips non-matches
phylo_tree <- as_tibble(next_tree) # On passe au format tibble plus pratique a manipuler

#### Modification de la nomenclature des labels des nodes de l arbre en vue des plots a venir ####
phylo_tree %>%
  arrange(label) %>%
  identity -> phylo_tree

j <- 1
# On ajoute une numerotation aux labels de certains nodes pour qu ils soient tous uniques
for (i in 329:Nnode(next_tree))
{
  if(phylo_tree[i + 1, 'label'] == phylo_tree[i, 'label'])
  {
    phylo_tree[i, 'label'] <- str_glue("{phylo_tree[i, 'label']}_{j}")
    j <- j + 1
  }
  else
  {
    phylo_tree[i, 'label'] <- str_glue("{phylo_tree[i, 'label']}_{j}")
    j <- 1
  }
}

phylo_tree %>%
  arrange(node) %>%
  identity -> phylo_tree

next_tree <- as.phylo(phylo_tree) # On repasse au format phylo pour pouvoir enregistrer l arbre sans risquer de l abimer

#### Enregistrement de l arbre au format phylo dans le fichier Species_tree.tree (meme resultat qu on parte de Taxo_result.tsv ou de New_Taxo_result.tsv) ####
write.tree(next_tree, "W:/ninon-species/output/Species_tree.tree")
