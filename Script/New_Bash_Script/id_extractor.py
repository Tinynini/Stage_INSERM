#!/usr/bin/python

import os

dir1 = "usefull/"
dir2 = "listes_id/"
dir3 = "listes_gene/"
end1 = '_liste_id.txt'
end2 = '_liste_gene.txt'

file_list = os.listdir(dir1)

for file in file_list :

    sseqid = open('uniq_sseqid.txt', "r")
    fichier = dir1 + file
    filename = (file[:-12])
    
    output = dir2 + filename + end1
    numgenes = dir3 + filename + end2
        
    liste_id = open(output, "w")
    liste_numgene = open(numgenes, "w")

    with open(fichier, "r") as usefull :

        numgene = []
        contiggene = []
        numARG = []
        contigARG = []

        for ligne in sseqid :

            if filename in ligne :

                numARG.append(ligne)
        
        line = usefull.readlines()

        for i in range(len(line)) :

            if i%2 == 0 :

                contiggene.append(line[i])

                if line[i + 1] in numARG :

                    contigARG.append(line[i])
                    
            if i%2 != 0 :

                numgene.append(line[i])

        for i in range(len(numgene)) :

            for j in range(len(numARG)) :

                liste_numgene.write(numgene[i])
               
                if i == 0 :

                    if numgene[i] == numARG[j] and contiggene[i + 1] == contigARG[j] :

                        liste_id.write(numgene[i + 1])

                elif i == len(numgene) :

                    if numgene[i] == numARG[j] and contiggene[i - 1] == contigARG[j] :

                        liste_id.write(numgene[i - 1])
                        
                else :
                
                    if numgene[i] == numARG[j] and contiggene[i - 1] == contigARG[j] :

                        liste_id.write(numgene[i - 1])
                        
                    if numgene[i] == numARG[j] and contiggene[i + 1] == contigARG[j] :

                        liste_id.write(numgene[i + 1])   

        usefull.close()

    liste_id.close()
    liste_numgene.close()
    sseqid.close()
