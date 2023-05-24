#library(tidyverse)

##################################################################
# Ninon ROBIN -- ninon.robin@inserm.fr                           #
# Utilite == generer des matrices d absence/presence GenexNiveau #
# Input == sliced_all_species_taxo.tsv et taxo_species.tsv       #
# Output == 21 fichiers Sliced_matrix_*.tsv                      #
##################################################################

#### Ouverture de sliced_all_species_taxo.tsv et taxo_species.tsv & recuperation des donnees dans une dataframe ####
all_species <- read_tsv('W:/ninon-species/output/Output_M2/AV_AP_ARG/Matrix/Dataframe/sliced_all_species_taxo.tsv', show_col_types = FALSE) %>% 
  as.data.frame() 

species <- read_tsv('W:/ninon-species/output/Output_M2/AV_AP_ARG/Matrix/Dataframe/taxo_species.tsv', col_types = 'cccccc') %>% 
  as.data.frame() 

species_matrix <- as.matrix(all_species[, -c(1,2)]) 
rownames(species_matrix) <- c(all_species[, 1])

write.table(species_matrix, "W:/ninon-species/output/Output_M2/AV_AP_ARG/Matrix/Matrice/Sliced_Matrix_species.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)

#### Pretraitement des donnees en vue de la creation de matrices d absence/presence GenexNiveau ####
level_name <- unlist(colnames(species)) # On extrait les labels des 6 niveaux taxonomiques etudies pour pouvoir travailler a un niveau donne plus facilement
curr_matrix <- species_matrix
uni_gene <- all_species$qseqid # On extrait la colonne des genes
n_gene <- length(uni_gene) 

for (i in 1:5) # Permet de parcourir les 5 niveaux taxonomiques etudies (d espece a classe)
{
  now_level <- as.data.frame(sort(unique(species[, i]))) # On extrait la colonne du niveau i 
  colnames(now_level) <- level_name[i] 
  
  for (j in (i + 1):6) # Permet de parcourir en parrallele du niveau i les j niveaux suivants
  {
    curr_level <- unique(species[, c(j, i)]) # On extrait simultanement les colonnes des niveaux j et i 
    # na_level_1 <- which(is.na(curr_level[, 1]) == TRUE) # On isole les lignes du niveau j contenant NA (== valeur non renseignee)
    # curr_level <- curr_level[-c(na_level_1),] # On supprimer ces lignes 
    #
    # if (i > 1) # Si le niveau i n est pas celui des especes (le seul qui ne peut pas contenir de NA parce que provenant des donnees de depart)
    # {
    #   na_level_2 <- which(is.na(curr_level[, 2]) == TRUE) # On isole les lignes du niveau i contenant NA (== valeur non renseignee)
    #   curr_level <- curr_level[-c(na_level_2),] # On supprimer ces lignes
    # }
    
    curr_level %>% # On reordonne a present les 2 colonnes en fonction de celle du niveau j
      arrange(level_name[j]) %>%
      identity() -> curr_level
    
    uni_level <- unlist(sort(unique(species[, j]))) # On extrait la colonne du niveau j
    n_level <- length(uni_level)
    
    gene_matrix <- curr_matrix
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
    path_start <- "W:/ninon-species/output/Output_M2/AV_AP_ARG/Matrix/Matrice/Sliced_Matrix_"
    path_end <- ".tsv"
    file_name <- str_glue("{path_start}{level_name[i]}_{level_name[j]}{path_end}") # Le nom de fichier est definit par une variable
    write.table(cross_matrix, file_name, sep = '\t', row.names = FALSE, col.names = TRUE)
    
    if (j == i + 1)
    {
      for (o in 1:ncol(cross_matrix))
      {
        for (p in 1:nrow(cross_matrix))
        {
          if (cross_matrix[p, o] != 0)
          {
            cross_matrix[p, o] <- 1
          }
        }
      }
      
      next_matrix <- cross_matrix
      new_file_name <- str_glue("{path_start}{level_name[j]}{path_end}") # Le nom de fichier est definit par une variable
      write.table(cross_matrix, new_file_name, sep = '\t', row.names = FALSE, col.names = TRUE)
    }
  }
  
  curr_matrix <- next_matrix
}
