#!/usr/bin/python

import os

dir1 = "listes_id/"
dir2 = "listes_gene/"
dir3 = "ffn/"
dir4 = "listes_ARG/"
dir5 = "listes_seq/"
end1 = '_uniq_liste_gene.txt'
end2 = '.ffn'
end3 = '_liste_ARG.txt'
end4 = '_liste_seq.ffn'

file_list = os.listdir(dir1)

for file in file_list :

    fichier = dir1 + file
    filename = (file[:-18])

    gene = dir2 + filename + end1
    fasta = dir3 + filename + end2
    args = dir4 + filename + end3
    output = dir5 + filename + end4
    
    liste_gene = open(gene, "r")
    ffn = open(fasta, "r")
    ARG = open(args, "r")
    
    liste_seq = open(output, "w")

    with open(fichier, "r") as liste_id :
    
        line = liste_gene.readlines()
        ligne = liste_id.readlines()
        elements = ffn.readlines()
        arg = ARG.readlines()
        
        element = ' '.join(elements)
        seq = element.split('>')

        for i in range(len(line)) :

            for j in range(len(ligne)) :

                if line[i] == ligne[j] and ligne [j] not in arg :

                    liste_seq.write('>') 
                    liste_seq.write(seq[i + 1]) 
       
    liste_gene.close()
    ffn.close()
    ARG.close()
    liste_seq.close()
    liste_id.close()
