#!/usr/bin/python

import os

liste_seq_ffn = open('/home/ninon.robin/2023_recup/output/liste_seq_ffn.ffn', "r")
uniq_liste_seq_ffn = open('/home/ninon.robin/2023_recup/output/uniq_liste_seq_ffn.ffn', "w")

seq = liste_seq_ffn.readlines()
dico_seq = {}

for i in range(0, len(seq)-1, 2) : 

    dico_seq[seq[i + 1]] = seq[i]

for cle, valeur in dico_seq.items() :

    uniq_liste_seq_ffn.write(valeur)
    uniq_liste_seq_ffn.write(cle)

liste_seq_ffn.close()
uniq_liste_seq_ffn.close()
