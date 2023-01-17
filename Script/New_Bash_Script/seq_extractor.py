#!/usr/bin/python

import os

dir1 = "/home/ninon.robin/listes_id/"
dir2 = "/home/ninon.robin/listes_gene/"
dir3 = "/home/ninon.robin/ffn/"
dir4 = "/home/ninon.robin/listes_seq/"
end1 = '_uniq_liste_gene.txt'
end2 = '.ffn'
end3 = '_liste_seq.ffn'

file_list = os.listdir(dir1)

for file in file_list :

    fichier = dir1 + file
    filename = (file[:-18])
    print(filename)

    gene = dir2 + filename + end1
    fasta = dir3 + filename + end2
    output = dir4 + filename + end3

    liste_gene = open(gene, "r")
    ffn = open(fasta, "r")
    liste_seq = open(output, "w")

    with open(fichier, "r") as liste_id :
    
        line = liste_gene.readlines()
        ligne = liste_id.readlines()
        elements = ffn.readlines()
        element = ' '.join(elements)
        seq = element.split('>')
        
        for i in range(len(line)) :

            for j in range(len(ligne)) :

                if line[i] == ligne[j] :

                    liste_seq.write('>') 
                    liste_seq.write(seq[i + 1])   

    liste_id.close()

liste_gene.close()
ffn.close()
liste_seq.close()