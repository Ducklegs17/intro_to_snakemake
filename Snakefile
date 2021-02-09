#!/bin/bash/

#List of assemblies to be assembled
STRAINS = ["C2999_S13","C2004_S15"]

# List of rules to be run on the head node.
localrules:
	all,
	get_data,
	subset_data,
	trim,

#The desired output file/files should be listed here.
rule all:
	input:
		expand("2_assembly/{STRAIN}/contigs.fasta", STRAIN = STRAINS),

rule get_data:
	output:
		"0_raw/C2999_S13_R1.fastq.gz",
		"0_raw/C2999_S13_R2.fastq.gz",
		"0_raw/C2004_S15_R1.fastq.gz",
		"0_raw/C2004_S15_R2.fastq.gz",
	shell:
		"""
		wget -O 0_raw/C2999_S13_R1.fastq.gz https://sra-pub-sars-cov2.s3.amazonaws.com/sra-src/SRR13418676/C2999_S13_L001_R1_001.fastq.gz.1
		wget -O 0_raw/C2999_S13_R2.fastq.gz https://sra-pub-sars-cov2.s3.amazonaws.com/sra-src/SRR13418676/C2999_S13_L001_R2_001.fastq.gz.1
		wget -O 0_raw/C2004_S15_R1.fastq.gz https://sra-pub-sars-cov2.s3.amazonaws.com/sra-src/SRR13418674/C2004_S15_L001_R1_001.fastq.gz.1
		wget -O 0_raw/C2004_S15_R2.fastq.gz https://sra-pub-sars-cov2.s3.amazonaws.com/sra-src/SRR13418674/C2004_S15_L001_R2_001.fastq.gz.1
		"""

rule subset_data:
	input:
		"0_raw/{STRAIN}_R{read}.fastq.gz",
	output:
		"1_subset/raw/{STRAIN}_R{read}.fastq.gz",
	conda:
		"envs/default.yaml",
	shell:
		"""
		seqtk sample -s100 {input} 7000 > {output}
		"""	

rule trim:
	input:
		r1 = "1_subset/raw/{STRAIN}_R1.fastq.gz",
		r2 = "1_subset/raw/{STRAIN}_R2.fastq.gz",
	output:
		r1 = "1_subset/trimmed/{STRAIN}_R1.fastq.gz",
		r2 = "1_subset/trimmed/{STRAIN}_R2.fastq.gz",
		html = "1_subset/trimmed/{STRAIN}_fastp.html",
	conda:
		"envs/default.yaml",
	shell:
		"""
		fastp -i {input.r1} -I {input.r2} -o {output.r1} -O {output.r2} -h {output.html}
		"""

rule assemble:
	input:
		r1 = "1_subset/trimmed/{STRAIN}_R1.fastq.gz",
		r2 = "1_subset/trimmed/{STRAIN}_R2.fastq.gz",
	output:
		"2_assembly/{STRAIN}/contigs.fasta",
	conda:
		"envs/default.yaml",
	params:
		out = "2_assembly/{STRAIN}/",
	shell:
		"""
		spades.py -1 {input.r1} -2 {input.r2} -o {params.out}
		"""
