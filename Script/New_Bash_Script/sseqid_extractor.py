#!/usr/bin/python

import os

def extract_sseqid(dir, file_list, output_file) :

    for file in file_list :

        fichier = dir + file

        with open(fichier, "r") as diamond :

            for line in diamond :
        
                if  len(line) - 1 != 0 :

                    mot = line.split()
                    sseqid = mot[1]

                    output_file.write(sseqid)
                    output_file.write('\n')
                    
        diamond.close()

sseqidAll = open('sseqid.txt', "w")

dir1 = "/home/ninon.robin/diamond_resfinder4/"
dir2 = "/home/ninon.robin/diamond_resfinderFG/"

file_list1 = os.listdir(dir1)
file_list2 = os.listdir(dir2)

extract_sseqid(dir1, file_list1, sseqidAll)
extract_sseqid(dir2, file_list2, sseqidAll)

sseqidAll.close()