library(tidyverse)

##############################################################################################
# Ninon ROBIN -- ninon.robin@inserm.fr                                                       #
# Utilite == generer des matrices pseudo-binaires d absence/presence GenexNiveau_i->Niveau_j #
# Input == sliced_all_species_taxo.tsv et 6 fichiers Sliced_matrix_'level_name[i]'.tsv       #                                  
# Output == 15 fichiers Sliced_matrix_'level_name[i]'_'level_name[j]'.tsv                    #
##############################################################################################

#### Ouverture de sliced_all_species_taxo.tsv & recuperation des donnees dans une dataframe ####
all_species <- read_tsv('W:/ninon-species/output/Output_M2/ARG/Dataframe/sliced_all_species_taxo.tsv', show_col_types = FALSE) %>% 
#all_species <- read_tsv('W:/ninon-species/output/Output_M2/AV_AP_ARG/Dataframe/sliced_all_species_taxo.tsv', show_col_types = FALSE) %>% 
  as.data.frame() 

#### Pretraitement des donnees en vue de la creation de matrices d absence/presence GenexLevel d un genre un peu different... ####
level <- as.data.frame(all_species[, c(7:12)]) # On extrait le contenu des colonnes associes aux 6 niveaux taxonomiques etudies
level_name <- unlist(colnames(all_species[, c(7:12)])) # On extrait aussi leurs labels pour pouvoir travailler a un niveau donne plus facilement
uni_gene <- sort(unique(all_species$qseqid)) # On extrait la colonne des genes
n_gene <- length(uni_gene) 

for (i in 1:5) # Permet de parcourir les 5 niveaux taxonomiques etudies (d espece a classe)
{
  now_level <- as.data.frame(sort(unique(level[, i]))) # On extrait la colonne du niveau i 
  colnames(now_level) <- level_name[i] 
  
  for (j in (i + 1):6) # Permet de parcourir en parrallele du niveau i les j niveaux suivants
  {
    curr_level <- as.data.frame(unique(level[, c(j, i)])) # On extrait simultanement les colonnes des niveaux j et i 
    na_level_1 <- which(is.na(curr_level[, 1]) == TRUE) # On isole les lignes du niveau j contenant NA (== valeur non renseignee)
    curr_level <- curr_level[-c(na_level_1),] # On supprimer ces lignes 
    
    if (i > 1) # Si le niveau i n est pas celui des especes (le seul qui ne peut pas contenir de NA parce que provenant des donnees de depart)
    {
      na_level_2 <- which(is.na(curr_level[, 2]) == TRUE) # On isole les lignes du niveau i contenant NA (== valeur non renseignee)
      curr_level <- curr_level[-c(na_level_2),] # On supprimer ces lignes 
    }
    
    curr_level %>% # On reordonne a present les 2 colonnes en fonction de celle du niveau j
      arrange(level_name[j]) %>%  
      identity() -> curr_level
    
    uni_level <- unlist(as.data.frame(sort(unique(curr_level[, 1])))) # On extrait la colonne du niveau j 
    n_level <- length(uni_level) 
    
    #### Ouverture & traitement de la matrice binaire associee au niveau i depuis son fichier nominatif ####
    path_start <- "W:/ninon-species/output/Output_M2/ARG/Matrice/Sliced_Matrix_"
    #path_start <- "W:/ninon-species/output/Output_M2/AV_AP_ARG/Matrice/Sliced_Matrix_" 
    path_end <- ".tsv" 
    file_name <- str_glue("{path_start}{level_name[i]}{path_end}") # Le nom de fichier est definit par une variable
    
    gene_matrix <- read_tsv(file_name, show_col_types = FALSE) 
    rownames(gene_matrix) <- uni_gene 
    gene_matrix <- t(gene_matrix) # On transpose la matrice pour avoir les representants du niveau i en ligne  
    gene_matrix <- cbind(now_level, gene_matrix) # On fusionne la colonne du niveau i a notre matrice 
    gene_matrix <- left_join(curr_level, gene_matrix, by = NULL) # On join les colonnes des niveaux j et i et la matrice sur les colonnes du niveau i de part et d autre
    gene_matrix <- t(gene_matrix[,-2]) # On supprime la colonne du niveau i & on retranspose la matrice
    colnames(gene_matrix) <- gene_matrix[1,] # On renomme les colonnes d apres le contenu de la ligne (anciennement colonne) du niveau j 
    gene_matrix <- as.data.frame(gene_matrix[-1,]) # On supprime la ligne du niveau j & on transforme la matrice en dataframe (necessaire pour pouvoir utiliser as.integer()) 
    
    for (n in 1:ncol(gene_matrix)) # On parcourt les colonnes (autrement dit les representants du niveau j) 
    {
      gene_matrix[, n] <- as.integer(c(gene_matrix[, n])) # On transforme le type du contenu de chaque colonnes en int (actuellement des str)
    } # N.B. : On a besoin d int pour la suite et on ne pouvait malheureusement pas appliquer as.integer() directement sur l ensemble de la matrice (sinon c est evidement ce que j aurais fait)
    
    gene_matrix <- as.matrix(gene_matrix) # On retransforme notre ex-matrice en matrice 
    
    #### Creaction d une matrice pseudo-binaire (0/1~n) d absence/presence des genes au niveau i au sein du niveau j ####
    cross_matrix <- matrix(data = 0, nrow = n_gene, ncol = n_level) 
    rownames(cross_matrix) <- uni_gene 
    colnames(cross_matrix) <- uni_level  
    
    for (k in 1:n_level) # On parcourt les k representants distincts du niveau j 
    { 
      # On va les chercher dans la colonne triee et dedoublonnee qu on a extrait precedement
      to_set <- which(curr_level[, 1] %in% uni_level[k]) # On isole les occurrences du representant k au sein du bloc 'niveau j + niveau i' 
      l <- length(to_set) 
      m <- gene_matrix[, c(to_set)] # On extrait de notre matrice binaire les colonnes de meme indice que les occurences trouvees
      # Pour la colonne associe au representant k dans la matrice pseudo-binaire :
      if (l > 1) # S il y a plus d une occurrence
      {
        cross_matrix[, k] <- rowSums(m) # On lui assigne comme contenu la somme des colonnes extraites si-avant de la matrice binaire 
      }
      else # Sinon 
      {
        cross_matrix[, k] <- m # On lui assigne comme contenu celui de l unique colonne extraite si-avant de la matrice binaire
      }
    } # N.B : Je sais c est un peu complique mais in fine ca donne un matrice Genex'Level j' avec 0 s il y a pas de match ou le nombre de representants du niveau i au sein du representant du niveau j se partageant le gene s il y a un match
    
    #### Enregistrement de la matrice pseudo-binaire ainsi obtenue dans un fichier nominatif ####
    new_path_start <- "W:/ninon-species/output/Output_M2/ARG/Matrice/Sliced_Matrix_"
    #new_path_start <- "W:/ninon-species/output/Output_M2/AV_AP_ARG/Matrice/Sliced_Matrix_"
    new_path_end <- ".tsv" 
    new_file_name <- str_glue("{new_path_start}{level_name[i]}_{level_name[j]}{new_path_end}") # Le nom de fichier est definit par une variable
    write.table(cross_matrix, new_file_name, sep = '\t', row.names = FALSE, col.names = TRUE) 
  }
}
