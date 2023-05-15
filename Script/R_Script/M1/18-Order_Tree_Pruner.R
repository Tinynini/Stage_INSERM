library(tidyverse)
library(tidytree)
library(ape)

#### Ouverture de bac120_r95.tree et de New_Parsed_taxonomy.tsv et de Taxo_result.tsv (ou de New_Taxo_result.tsv) & recuperation des donnees ####
tree <- read.tree('W:/ninon-species/data/bac120/bac120_r95.tree')
tree_df <- as_tibble(tree) # On passe au format tibble plus pratique a manipuler

all_species <- read_tsv('W:/ninon-species/output/Output_M1/Dataframe/Taxo_result.tsv') %>%
  #all_species <- read_tsv('W:/ninon-species/output/Output_M1/Dataframe/New_Taxo_result.tsv') %>% 
  as.data.frame()

# On extrait les colonnes 'Order' et 'order_shared_by' (qui fait juste office de marqueur) de la dataframe
uni_order <- as.data.frame(sort(unique(all_species[, 'Order'])))
colnames(uni_order) <- 'Order'
uni_order <- unique(left_join(uni_order, all_species[, c('Order', 'order_shared_by')], by = c('Order' = 'Order')))

# On extrait les colonnes 'sseqid' et 'Order' de la table de taxonomie
taxo <- read_tsv('W:/ninon-species/output/Table_taxonomie/New_Parsed_taxonomy.tsv') %>% 
  as.data.frame()

small_taxo <- taxo[, c(1, 5)]

#### Join de l arbre avec les ordres de la table de taxonomie (== remplacer les labels par les ordres associes) ####
taxo_tree <- left_join(tree_df, small_taxo, by = c('label' = 'sseqid')) # On join sur les labels de sequences bacteriennes
taxo_tree[1:Ntip(tree), 'label'] <- taxo_tree[1:Ntip(tree), 'Order'] # On remplace les labels de tips (pas de nodes) par les ordres associes 
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

#### Join de l arbre avec les ordres de notre dataframe (== pruner l arbre en ne gardant que les ordres presents dans notre dataframe) ####
phylo_tree <- left_join(taxo_tree, uni_order, by = c('label' = 'Order')) # On join sur les ordres
n_tips <- nrow(phylo_tree) - Nnode(new_tree)
na_label <- is.na(phylo_tree[1:n_tips, 'order_shared_by']) # On extrait les labels des tips matches lors du join
order <- which(na_label == FALSE) 
phylo_tree[order, 'order_shared_by'] <- 1 # On standardise la valeur de la colonne 'order_shared_by' pour ces tips
phylo_tree <- unique(phylo_tree) # On supprime les doublons
na_label <- is.na(phylo_tree[1:Ntip(new_tree), 'order_shared_by']) # On extrait les labels des tips non-matches
na_order <- which(na_label == TRUE)
next_tree <- as.phylo(phylo_tree) # On passe au format phylo pour pouvoir pruner l arbre
next_tree <- drop.tip(next_tree, na_order) # On prune l arbre en supprimant les tips non-matches
phylo_tree <- as_tibble(next_tree) # On passe au format tibble plus pratique a manipuler

#### Modification de la nomenclature des labels des nodes de l arbre en vue des plots a venir ####
phylo_tree %>%
  arrange(label) %>%
  identity -> phylo_tree

j <- 1
# On ajoute une numerotation aux labels de certains nodes pour qu ils soient tous uniques
for (i in 16:Nnode(next_tree)) 
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

#### Enregistrement de l arbre au format phylo dans le fichier Order_tree.tree (meme resultat qu on parte de Taxo_result.tsv ou de New_Taxo_result.tsv) ####
write.tree(next_tree, "W:/ninon-species/output/Output_M1/Arbre/Order_tree.tree")