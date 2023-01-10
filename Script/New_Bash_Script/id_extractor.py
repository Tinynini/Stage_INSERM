#!/usr/bin/python

import os

dir1 = "/home/ninon.robin/usefull/"
dir2 = "/home/ninon.robin/listes_id/"

file_list = os.listdir(dir1)

for file in file_list :

    sseqid = open('/home/ninon.robin/uniq_sseqid.txt', "r")

    fichier = dir1 + file
    filename = (file[:-12])
    print(filename)
    output = dir2 + filename + '_liste_id.txt'

    liste_id = open(output, "w")

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

        print(numARG)
        print(contigARG)

        for i in range(len(numgene)) :

            for j in range(len(numARG)) :

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
    sseqid.close()