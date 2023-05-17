library(tidyverse)
library(png)
library(tidytree)
library(ape)
library(ggtree) 

#### A faire : ####

# 1 : Remarque Nicolas (table excel) + 3 nouveaux graphs (photo antoine)
# 2 : Switcher en bash pour pouvoir choisir si on travaille en sliced ou total (Tous sauf 01 et 03)/en anglais ou français (07 08 et 10)/avec quels reps (07 et 10) a l avance !!
# 3 (Optionnel) : Checker l existance des inputs avant 05 06 et 09 (comment gerer ca pour plusieurs inputs ?) ??

#### Main : ####
# N.B. : Verifier que le traitement 'a la main' des cas particuliers dans 01 03 et 04 est toujours adapte (normalement oui) si les donnees de depart changent !

# if (file.exists('W:/ninon-species/output/Output_M2/ARG/Dataframe/all_species.tsv') == FALSE)
# {
#   source('W:/ninon-species/script/Script_M2/01-Species_filtering.R') # /!\ Ca prend 3/4h a 2h !!
# } else if (file.exists('W:/ninon-species/output/Output_M2/ARG/Dataframe/sliced_all_species_clust.tsv') == FALSE)
# {
#   source('W:/ninon-species/script/Script_M2/02-All_species_cluster.R') 
# } else 
# {
#   source('W:/ninon-species/script/Script_M2/03-Taxonomy_parser.R') 
# }

if (file.exists('W:/ninon-species/output/Output_M2/AV_AP_ARG/Dataframe/sliced_all_species_clust') == FALSE)
{
  source('W:/ninon-species/script/Script_M2/01-02_alt.R') 
}

#if (file.exists('W:/ninon-species/output/Output_M2/ARG/Dataframe/sliced_all_species_taxo.tsv') == FALSE)
if (file.exists('W:/ninon-species/output/Output_M2/AV_AP_ARG/Dataframe/sliced_all_species_taxo.tsv') == FALSE)
{
  source('W:/ninon-species/script/Script_M2/04-Taxo_Join.R') 
} else 
{
  source('W:/ninon-species/script/Script_M2/05-Matrix_Binaire.R') 
  source('W:/ninon-species/script/Script_M2/06-Matrix_Pseudo_Binaire.R') 
  source('W:/ninon-species/script/Script_M2/07-Matrix_Plot.R') 
  source('W:/ninon-species/script/Script_M2/08-Taxo_Filter_Plot.R') 
  source('W:/ninon-species/script/Script_M2/09-Tree_Pruner.R') 
  source('W:/ninon-species/script/Script_M2/10-Tree_Plot.R') 
}
