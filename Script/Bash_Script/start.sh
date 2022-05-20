#!/bin/bash

/opt/progs/vsearch

<< 'comment'
vsearch --allpairs_global FILENAME --id 0.5 --alnout FILENAME
vsearch --cluster_size FILENAME --id 0.97 --centroids FILENAME
vsearch --derep_fulllength FILENAME --output FILENAME
vsearch --fastq_chars FILENAME
vsearch --fastq_convert FILENAME --fastqout FILENAME --fastq_ascii 64
vsearch --fastq_eestats FILENAME --output FILENAME
vsearch --fastq_eestats2 FILENAME --output FILENAME
vsearch --fastq_mergepairs FILENAME --reverse FILENAME --fastqout FILENAME
vsearch --fastq_stats FILENAME --log FILENAME
vsearch --fastx_filter FILENAME --fastaout FILENAME --fastq_trunclen 100
vsearch --fastx_getseq FILENAME --label LABEL --fastaout FILENAME
vsearch --fastx_mask FILENAME --fastaout FILENAME
vsearch --fastx_revcomp FILENAME --fastqout FILENAME
vsearch --fastx_subsample FILENAME --fastaout FILENAME --sample_pct 1
vsearch --makeudb_usearch FILENAME --output FILENAME
vsearch --search_exact FILENAME --db FILENAME --alnout FILENAME
vsearch --sff_convert FILENAME --output FILENAME --sff_clip
vsearch --shuffle FILENAME --output FILENAME
vsearch --sintax FILENAME --db FILENAME --tabbedout FILENAME
vsearch --sortbylength FILENAME --output FILENAME
vsearch --sortbysize FILENAME --output FILENAME
vsearch --uchime_denovo FILENAME --nonchimeras FILENAME
vsearch --uchime_ref FILENAME --db FILENAME --nonchimeras FILENAME
vsearch --usearch_global FILENAME --db FILENAME --id 0.97 --alnout FILENAME

Other commands: cluster_fast, cluster_smallmem, cluster_unoise, derep_prefix,
                fastq_filter, fastq_join, fastx_getseqs, fastx_getsubseqs,
                maskfasta, rereplicate, uchime2_denovo, uchime3_denovo,
                udb2fasta, udbinfo, udbstats, version

cat XXXXX | grep '>'
comment