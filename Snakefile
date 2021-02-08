#!/bin/bash/

localrules:
	all,
	get_data,
	subset_data,

rule all:
	input:
		"3_ass_quality/C2004_S15/report.tsv",

rule get_data:
	output:
		"0_raw/C2004_S15_L001_R1_001.fastq.gz",
		"0_raw/C2004_S15_L001_R2_001.fastq.gz", 
	shell:
		"""
		wget -O 0_raw/C2004_S15_L001_R1_001.fastq.gz https://sra-pub-sars-cov2.s3.amazonaws.com/sra-src/SRR13418674/C2004_S15_L001_R1_001.fastq.gz.1
		wget -O 0_raw/C2004_S15_L001_R2_001.fastq.gz https://sra-pub-sars-cov2.s3.amazonaws.com/sra-src/SRR13418674/C2004_S15_L001_R2_001.fastq.gz.1
		"""

rule subset_data:
	input:
		"0_raw/C2004_S15_L001_R{read}_001.fastq.gz",
	output:
		"1_subset/raw/C2004_S15_L001_R{read}_001.fastq.gz",
	conda:
		"envs/default.yaml",
	shell:
		"""
		seqtk sample -s100 {input} 7000 > {output}
		"""	

rule trim:
	input:
		r1 = "1_subset/raw/C2004_S15_L001_R1_001.fastq.gz",
		r2 = "1_subset/raw/C2004_S15_L001_R2_001.fastq.gz",
	output:
		r1 = "1_subset/trimmed/C2004_S15_L001_R1_001.fastq.gz",
		r2 = "1_subset/trimmed/C2004_S15_L001_R2_001.fastq.gz",
		html = "1_subset/trimmed/C2004_S15_L001_fastp.html",
	conda:
		"envs/default.yaml",
	shell:
		"""
		fastp -i {input.r1} -I {input.r2} -o {output.r1} -O {output.r2} -h {output.html}
		"""

rule assemble:
	input:
		r1 = "1_subset/trimmed/C2004_S15_L001_R1_001.fastq.gz",
		r2 = "1_subset/trimmed/C2004_S15_L001_R2_001.fastq.gz",
	output:
		"2_assembly/C2004_S15/contigs.fasta",
	conda:
		"envs/default.yaml",
	shell:
		"""
		spades.py -1 {input.r1} -2 {input.r2} -o 2_assembly/C2004_S15
		"""

rule quast:
	input:
		"2_assembly/C2004_S15/contigs.fasta",
	output:
		"3_ass_quality/C2004_S15/report.tsv",
	conda:
		"envs/default.yaml",
	shell:
		"""
		quast {input} -o 3_ass_quality/C2004_S15
		"""
