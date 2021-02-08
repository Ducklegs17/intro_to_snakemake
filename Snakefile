#!/bin/bash/

# Associates data links (taken from ncbi) with output file names. Needs to be populated manually.
links = {"C2999_S13_R1" : "https://sra-pub-sars-cov2.s3.amazonaws.com/sra-src/SRR13418676/C2999_S13_L001_R1_001.fastq.gz.1",
	"C2999_S13_R2" : "https://sra-pub-sars-cov2.s3.amazonaws.com/sra-src/SRR13418676/C2999_S13_L001_R2_001.fastq.gz.1",
	"C2004_S15_R1" : "https://sra-pub-sars-cov2.s3.amazonaws.com/sra-src/SRR13418674/C2004_S15_L001_R1_001.fastq.gz.1",
	"C2004_S15_R2" : "https://sra-pub-sars-cov2.s3.amazonaws.com/sra-src/SRR13418674/C2004_S15_L001_R2_001.fastq.gz.1"}

#Make the association above accessible with a function of wildcards
def chainfile2link(wildcards):
    return links[wildcards.chainfile]


#List of assemblies to be assembled (should match with the first part of the output file names specified in the 'links' association above
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
		"0_raw/{chainfile}.fastq.gz",
	params:
		link = chainfile2link,
	shell:
		"""
		wget -N -O {output} {params.link}
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
#Rules can be benchmarked using the 'benchmark' keyword. 
#Generates a .tsv with runtimes and RAM usage.
#By just providing the path to the benchmark file, it will run only once.
#The commented out line would cause the rule to be run three times and data from all three runs would appear in the .tsv
rule trim:
	input:
		r1 = "1_subset/raw/{STRAIN}_R1.fastq.gz",
		r2 = "1_subset/raw/{STRAIN}_R2.fastq.gz",
	output:
		r1 = "1_subset/trimmed/{STRAIN}_R1.fastq.gz",
		r2 = "1_subset/trimmed/{STRAIN}_R2.fastq.gz",
		html = "1_subset/trimmed/{STRAIN}_fastp.html",
	benchmark:
		"benchmarks/trim/{STRAIN}.tsv",
#		repeat("benchmarks/trim/{STRAIN}.tsv", 3)
	log:
		"logs/trim/{STRAIN}.tsv",
	conda:
		"envs/default.yaml",
	shell:
		"""
		(fastp -i {input.r1} -I {input.r2} -o {output.r1} -O {output.r2} -h {output.html}) 2> {log}
		"""

# The format of time (measured in minutes) can also be applied to memory and cpu if desired.
rule assemble:
	input:
		r1 = "1_subset/trimmed/{STRAIN}_R1.fastq.gz",
		r2 = "1_subset/trimmed/{STRAIN}_R2.fastq.gz",
	output:
		"2_assembly/{STRAIN}/contigs.fasta",
	resources:
		time = lambda wildcards, input: (2 if wildcards.STRAIN == "C2004_S15" else 3),
		mem_mb=lambda wildcards, attempt: attempt * 550,
		cpu = 1,
	conda:
		"envs/default.yaml",
	params:
		out = "2_assembly/{STRAIN}/",
	shell:
		"""
		spades.py -1 {input.r1} -2 {input.r2} -o {params.out}
		"""
