library(tidyverse)
library(tidytree)
library(ape)
library(ggtree) 

#### A faire : ####

# 1 : Remarque Nicolas (table excel) + 3 nouveaux graphs (photo antoine)
# 2 : Switcher en bash pour pouvoir choisir si on travaille en sliced ou total (Tous sauf 01 et 03)/en anglais ou français (07 08 et 10)/avec quels reps (07 et 10) a l avance !!
# 3 (Optionnel) : tester existance fichiers pour plusieurs inputs ??

#### Main : ####
# N.B. : Verifier les graphs sur l ensemble des especes (pas possible juste avec les vibrio)

source('W:/ninon-species/script/Script_M2/AV_AP_ARG/Matrix/01-02_alt.R') 
source('W:/ninon-species/script/Script_M2/AV_AP_ARG/Matrix/03-Taxonomy_parser.R')
source('W:/ninon-species/script/Script_M2/AV_AP_ARG/Matrix/04-Taxo_Join.R') 
source('W:/ninon-species/script/Script_M2/AV_AP_ARG/Matrix/05-06_alt.R') 
source('W:/ninon-species/script/Script_M2/AV_AP_ARG/Matrix/07-Matrix_Plot.R') 
source('W:/ninon-species/script/Script_M2/AV_AP_ARG/Matrix/08-Taxo_Filter_Plot.R') 
source('W:/ninon-species/script/Script_M2/AV_AP_ARG/Matrix/09-Tree_Pruner.R') 
source('W:/ninon-species/script/Script_M2/AV_AP_ARG/Matrix/10-Tree_Plot.R') 
