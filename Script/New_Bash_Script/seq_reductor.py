#!/usr/bin/python

import os

all_seq = open('all_seq.ffn', "r")
clean_all_seq = open('clean_all_seq.ffn', "w")

elements = all_seq.readlines()

element = ''.join(elements)
seq = element.split('>')

for i in range(len(seq)) :
   
    sequence = ''.join(seq[i]) 
    line = sequence.split('\n')

    for j in range(len(line)) :
        
        if 'GCF_' not in line[j] :

            clean_all_seq.write(line[j])
            clean_all_seq.write('\n') 
        else :
            clean_all_seq.write('>')
    
all_seq.close()
clean_all_seq.close()

clean_all_seq = open('clean_all_seq.ffn', "r")
uniq_all_seq = open('uniq_all_seq.ffn', "w")

elements = clean_all_seq.readlines()
element = ''.join(elements) 
seq = element.split('>')
seq[:] = [x for i, x in enumerate(seq) if i == seq.index(x)]

for i in range(len(seq)) :

    uniq_all_seq.write(seq[i]) 
    uniq_all_seq.write('> seq\n')
    
clean_all_seq.close()
uniq_all_seq.close()
